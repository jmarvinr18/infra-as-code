

output "ssh_private_key" {
    sensitive = true
    value = module.ssh.private_key
}