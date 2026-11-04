output "alb_dns" {
  value = module.alb.dns_name
}

output "private_ip" {
  value = {
    for k, v in local.instances : k => module.instances[k].private_ip
  }
}

output "public_ip" {
  value = {
    for k, v in local.instances : k => module.instances[k].public_ip
  }
}