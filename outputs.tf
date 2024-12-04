output "ec2_public_dns" {
  value = module.ec2_instances[*].public_dns
}