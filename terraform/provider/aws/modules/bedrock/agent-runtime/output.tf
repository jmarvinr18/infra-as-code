output "arn" {
  value = aws_bedrockagentcore_agent_runtime.this.agent_runtime_arn
}

output "agent_runtime_version" {
  value = aws_bedrockagentcore_agent_runtime.this.agent_runtime_version
}