module "dev_app_deployment" {
  source = "../modules/demo"

  personal_ip    = var.personal_ip
  alerting_email = var.alerting_email
  environment    = var.environment
}

output "dns" {
  value = module.dev_app_deployment.alb_dns
}