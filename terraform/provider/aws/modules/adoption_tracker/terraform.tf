terraform {
  required_version = ">= 1.6"

  required_providers {
    # 6.x for aws_bedrockagentcore_agent_runtime and the Serverless v2
    # scale-to-zero arguments; both are recent enough to be worth pinning
    # the floor rather than discovering the gap during an apply.
    aws     = { source = "hashicorp/aws", version = ">= 6.0" }
    archive = { source = "hashicorp/archive", version = ">= 2.4" }
    random  = { source = "hashicorp/random", version = ">= 3.5" }
  }
}
