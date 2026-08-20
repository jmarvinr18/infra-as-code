# ─────────────────────────────────────────────────────────────────────────────
# Scheduling.
#
# Three rules, all invoking a Lambda directly. EventBridge needs no role for a
# Lambda target — the resource-based permission below is what authorises it —
# and each target carries the DLQ so an undeliverable invocation is captured
# rather than discarded.
# ─────────────────────────────────────────────────────────────────────────────

locals {
  schedules = {
    briefing = {
      function            = "briefing"
      schedule_expression = var.briefing_schedule_expression
      description         = "Regenerates leadership briefings so dashboard traffic does not become agent invocations"
      input               = jsonencode({ source = "schedule", task = "generate_briefing" })
    }

    feedback_check = {
      function            = "feedback"
      schedule_expression = var.feedback_check_schedule_expression
      description         = "Daily sweep for users who have crossed their feedback threshold"
      input               = jsonencode({ source = "schedule", task = "check_due" })
    }

    embedding = {
      function            = "embedding"
      schedule_expression = var.embedding_schedule_expression
      description         = "Embeds new barriers and folds them into the theme clusters"
      input               = jsonencode({ source = "schedule", task = "embed_barriers" })
    }
  }
}

module "schedule" {
  for_each = local.schedules
  source   = "../eventbridge/rule"

  name                = "${local.name}-${replace(each.key, "_", "-")}"
  description         = each.value.description
  schedule_expression = each.value.schedule_expression
  state               = var.schedules_enabled ? "ENABLED" : "DISABLED"

  tags = local.tags
}

module "schedule_target" {
  for_each = local.schedules
  source   = "../eventbridge/target"

  rule_name = module.schedule[each.key].name
  target_id = "${local.name}-${replace(each.key, "_", "-")}"
  arn       = module.function[each.value.function].arn
  input     = each.value.input

  retry_policy = {
    maximum_event_age_in_seconds = 3600
    maximum_retry_attempts       = 2
  }

  # Where the invocation goes once the retries are spent. Without this, a
  # scheduled run that never lands leaves no trace beyond a metric nobody has
  # an alarm on.
  dead_letter_arn = module.dlq.arn
}

resource "aws_lambda_permission" "schedule" {
  for_each = local.schedules

  statement_id  = "AllowExecutionFrom-${replace(each.key, "_", "-")}"
  action        = "lambda:InvokeFunction"
  function_name = module.function[each.value.function].function_name
  principal     = "events.amazonaws.com"
  source_arn    = module.schedule[each.key].arn
}

# EventBridge has to be allowed to write to the queue it dead-letters into;
# the queue's default policy is owner-only.
resource "aws_sqs_queue_policy" "eventbridge_dlq" {
  queue_url = module.dlq.url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowEventBridgeDeadLettering"
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = module.dlq.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = [for k, _ in local.schedules : module.schedule[k].arn]
          }
        }
      }
    ]
  })
}
