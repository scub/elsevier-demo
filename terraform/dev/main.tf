module "app_dev" {
  source = "../modules/demo"

  personal_ip    = var.personal_ip
  alerting_email = var.alerting_email
  environment    = var.environment
}

output "dns" {
  value = try(module.app_dev.alb_dns, "")
}

output "state_bucket" {
  value = try(module.app_dev.buckets["state_bucket"], "")
}

output "github_actions_role" {
  value = try(module.app_dev.github_actions_role)
}