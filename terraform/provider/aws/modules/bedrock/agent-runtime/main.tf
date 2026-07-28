resource "aws_bedrockagentcore_agent_runtime" "this" {
  agent_runtime_name = var.agent_runtime_name
  role_arn           = var.role_arn

  agent_runtime_artifact {
    container_configuration {
      container_uri = var.artifact_container_uri
    }
  }

  network_configuration {
    network_mode = var.network_mode
  }
}


resource "aws_bedrockagentcore_agent_runtime_endpoint" "example" {
  name             = var.endpoint_name
  agent_runtime_id = aws_bedrockagentcore_agent_runtime.this.agent_runtime_id
  description      = var.endpoint_description
}