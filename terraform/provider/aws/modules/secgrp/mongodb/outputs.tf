output "mongo_sg_id" {
  value       = aws_security_group.mgcluster_sg.id
  description = "The ID of the Security Group for MongoDB Clustering"
}

output "mongo_alb_sg_id" {
  value       = aws_security_group.mgcluster_alb_sg.id
  description = "The ID of the ALB Security Group for MongoDB Clustering"
}