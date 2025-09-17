resource "aws_efs_mount_target" "this" {
  file_system_id = aws_efs_file_system.foo.id
  subnet_id      = aws_subnet.alpha.id
}
