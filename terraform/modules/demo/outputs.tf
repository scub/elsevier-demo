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

output "buckets" {
  value = {
    for k, v in local.buckets : k => module.s3_buckets[k].s3_bucket_id
  }
}