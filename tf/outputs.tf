output "bastion_host_ip" {
  value       = aws_instance.bastion-host-1.public_ip
  description = "Bastion Host Public IP Address"
}
