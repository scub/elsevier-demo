module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 10.5"

  name    = join("", [replace(local.name_prefix, "_", "-"), "web"])
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  listeners = {
    http_access = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "webservers"
      }
    }
  }

  target_groups = {
    webservers = {
      name_prefix                       = "${replace(local.name_prefix, "_", "-")}web-"
      protocol                          = "HTTP"
      port                              = 8000
      target_type                       = "instance"
      deregistration_delay              = 10
      load_balancing_cross_zone_enabled = true
      create_attachment                 = false

      health_check = {
        enabled             = true
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 3
        interval            = 30
        timeout             = 5
      }
    }
  }

  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  tags = local.default_tags
}
