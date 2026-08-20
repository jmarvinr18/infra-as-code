# ─────────────────────────────────────────────────────────────────────────────
# Insight layer.
#
# The briefing agent is a LangGraph graph on AgentCore Runtime. AgentCore is
# the hosting environment; LangGraph is what runs inside it, and the reason for
# the graph rather than a plain chain is one edge: verify_grounding loops back
# to revise when a cited figure does not appear in tool output. A chain cannot
# loop; a graph can.
#
# Terraform owns three things here — the repository the container image lands
# in, the runtime that runs it, and the guardrail wrapped around the model. The
# graph itself is application code and lives in the agent's own repository.
#
# The grounding rule is not enforced by the guardrail. It is enforced by
# parsing the figures out of the draft and asserting each one appears in what
# the tools returned: deterministic, free, and defensible in a way that an LLM
# checking an LLM is not. The guardrail is the outer net.
# ─────────────────────────────────────────────────────────────────────────────

# Declared here rather than through modules/ecr, which pins the AWS provider
# to ~> 5.35 — a constraint that cannot coexist with the >= 6.0 that
# aws_bedrockagentcore_agent_runtime needs. Relaxing the shared module's pin
# would drag every other stack that uses it onto a new major provider version,
# which is not a side effect this stack gets to cause.
resource "aws_ecr_repository" "insight_agent" {
  count = var.create_ecr_repository ? 1 : 0

  name                 = "${local.name}-insight-agent"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.tags
}

resource "aws_ecr_lifecycle_policy" "insight_agent" {
  count = var.create_ecr_repository ? 1 : 0

  repository = aws_ecr_repository.insight_agent[0].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 10
        description  = "Keep no more than 20 images."
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 20
        }
        action = { type = "expire" }
      }
    ]
  })
}

module "guardrail" {
  count  = var.create_guardrail ? 1 : 0
  source = "../bedrock/guardrail"

  name        = "${local.name}-briefing"
  description = "Outer net for leadership briefings — the citation check in the graph is the real control"

  blocked_outputs_messaging = "A grounded briefing could not be produced from the available data."

  contextual_grounding_filters = [
    { type = "GROUNDING", threshold = var.guardrail_grounding_threshold },
    { type = "RELEVANCE", threshold = var.guardrail_relevance_threshold },
  ]

  content_filters = [
    # A briefing is generated from staff comments, which are an untrusted
    # input path into the model whatever the prompt says.
    { type = "PROMPT_ATTACK", input_strength = "HIGH", output_strength = "NONE" },
    { type = "MISCONDUCT", input_strength = "MEDIUM", output_strength = "MEDIUM" },
  ]

  # Barriers are free text written by staff, and people name colleagues in
  # them. Anonymise rather than block: the theme is still useful once the
  # person is out of it.
  pii_entities = [
    { type = "NAME", action = "ANONYMIZE" },
    { type = "EMAIL", action = "ANONYMIZE" },
    { type = "PHONE", action = "ANONYMIZE" },
  ]

  tags = local.tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Execution role for the runtime.
#
# The agent reads data only through the Metrics Lambda's HTTP routes, so it has
# no database permissions at all — no rds-data, no secret. That is what makes
# "the agent cannot report on anything its tools did not return" a property of
# IAM rather than a hope about the prompt.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_iam_role" "insight_agent" {
  count = var.create_insight_agent ? 1 : 0

  name = "${local.name}-insight-agent"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "bedrock-agentcore.amazonaws.com" }
        Action    = "sts:AssumeRole"
        Condition = {
          StringEquals = { "aws:SourceAccount" = var.account_id }
          ArnLike      = { "aws:SourceArn" = "arn:aws:bedrock-agentcore:${var.region}:${var.account_id}:*" }
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "insight_agent" {
  count = var.create_insight_agent ? 1 : 0

  name = "${local.name}-insight-agent"
  role = aws_iam_role.insight_agent[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid    = "InvokeBriefingModel"
          Effect = "Allow"
          Action = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
          Resource = [
            "arn:aws:bedrock:${var.region}::foundation-model/${var.briefing_model_id}",
            "arn:aws:bedrock:${var.region}:${var.account_id}:inference-profile/*",
          ]
        },
        {
          Sid      = "WriteOwnLogs"
          Effect   = "Allow"
          Action   = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"]
          Resource = ["arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/bedrock-agentcore/*"]
        },
        {
          Sid      = "PullAgentImage"
          Effect   = "Allow"
          Action   = ["ecr:GetAuthorizationToken"]
          Resource = ["*"]
        },
      ],
      var.create_ecr_repository ? [
        {
          Sid      = "ReadAgentImageLayers"
          Effect   = "Allow"
          Action   = ["ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer", "ecr:BatchCheckLayerAvailability"]
          Resource = ["arn:aws:ecr:${var.region}:${var.account_id}:repository/${local.name}-insight-agent"]
        }
      ] : [],
      var.create_guardrail ? [
        {
          Sid      = "ApplyGuardrail"
          Effect   = "Allow"
          Action   = ["bedrock:ApplyGuardrail"]
          Resource = [module.guardrail[0].arn]
        }
      ] : [],
    )
  })
}

module "insight_agent" {
  count  = var.create_insight_agent ? 1 : 0
  source = "../bedrock/agent-runtime"

  agent_runtime_name = replace("${local.name}_insight_agent", "-", "_")
  role_arn           = aws_iam_role.insight_agent[0].arn

  artifact_container_uri = coalesce(
    var.insight_agent_image_uri,
    var.create_ecr_repository ? "${aws_ecr_repository.insight_agent[0].repository_url}:latest" : null,
  )

  network_mode = var.insight_agent_network_mode

  endpoint_name        = "DEFAULT"
  endpoint_description = "Leadership briefing agent for ${local.name}"
}

# ─────────────────────────────────────────────────────────────────────────────
# Background functions.
#
# Declared here rather than in ingest.tf because their permissions depend on
# the Bedrock resources above. Both are invoked asynchronously — by EventBridge
# — so unlike the request handlers they can use Lambda's own dead-letter path.
# ─────────────────────────────────────────────────────────────────────────────

locals {
  background_functions = {
    embedding = {
      handler     = "handlers.embedding.lambda_handler"
      description = "Embeds free-text barriers and clusters them into named themes"
      timeout     = var.embedding_lambda_timeout
      statements = concat(local.data_api_statements, [
        {
          Sid      = "EmbedAndLabelBarriers"
          Effect   = "Allow"
          Action   = ["bedrock:InvokeModel"]
          Resource = local.bedrock_model_arns
        },
      ])
      environment = {
        EMBEDDING_MODEL_ID         = var.embedding_model_id
        LABELLING_MODEL_ID         = var.labelling_model_id
        CLUSTER_DISTANCE_THRESHOLD = tostring(var.cluster_distance_threshold)
      }
    }

    briefing = {
      handler     = "handlers.briefing.lambda_handler"
      description = "Triggers the insight agent and caches the briefing it returns"
      timeout     = var.lambda_timeout
      statements = concat(local.data_api_statements, var.create_insight_agent ? [
        {
          Sid      = "InvokeInsightAgent"
          Effect   = "Allow"
          Action   = ["bedrock-agentcore:InvokeAgentRuntime"]
          Resource = ["${module.insight_agent[0].arn}", "${module.insight_agent[0].arn}/*"]
        }
      ] : [])
      environment = merge(
        { BRIEFING_MODEL_ID = var.briefing_model_id },
        var.create_insight_agent ? { AGENT_RUNTIME_ARN = module.insight_agent[0].arn } : {},
        var.create_guardrail ? {
          GUARDRAIL_ID      = module.guardrail[0].id
          GUARDRAIL_VERSION = module.guardrail[0].version
        } : {},
      )
    }
  }

  # Only the briefing function is also reachable over HTTP, for the demo's
  # regenerate control. The embedding job runs on a schedule and nothing else.
  routed_background_functions = {
    briefing = local.background_functions.briefing
  }
}
