locals {
  autoscaling_groups = {
    webserver = {
      min_size              = 1
      max_size              = 3
      instance_name         = "${local.name_prefix}web"
      create_security_group = false
      security_groups       = [module.web_sg.id]
      subnets               = module.vpc.private_subnets
      user_data = templatefile("${path.module}/files/webserver.userdata.sh", {
        asset_bucket          = module.s3_bucket["web_assets"].s3_bucket_id,
        secretsmanager_secret = module.secrets_manager.secret_arn,
      })
    }
  }
  instances = {
    bastion = {
      instance_name               = "${local.name_prefix}bastion"
      associate_public_ip_address = true
      create_security_group       = true
      subnet_id                   = element(module.vpc.public_subnets, 0)
      user_data = templatefile("${path.module}/files/bastion.userdata.sh", {
        asset_bucket = module.s3_bucket["web_assets"].s3_bucket_id
      })
      ingress_rules = {
        allow-http = {
          from_port   = 22
          to_port     = 22
          ip_protocol = "tcp"
          cidr_ipv4   = "${var.personal_ip}/32"
        }
      }
    }
  }
}


module "web_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0"

  name = "${local.name_prefix}web"

  vpc_id = module.vpc.vpc_id
  tags = {
    "Name" = "${local.name_prefix}web_ext"
  }

  ingress_rules = {
    allow-alb-http = {
      from_port                    = 8000
      to_port                      = 8000
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.alb.security_group_id
      description                  = "Allow traffic from the ALB"
    }
    allow-bastion-http = {
      from_port   = "8000"
      to_port     = "8000"
      ip_protocol = "tcp"
      cidr_ipv4   = "${module.instances["bastion"].private_ip}/32"
    }
    allow-bastion-ssh = {
      from_port   = "22"
      to_port     = "22"
      ip_protocol = "tcp"
      cidr_ipv4   = "${module.instances["bastion"].private_ip}/32"
    }
    deny-all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  egress_rules = {
    allow-all = {
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "-1"
    }
  }
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 9.3"

  for_each = local.autoscaling_groups

  name = each.value.instance_name

  min_size         = try(each.value.min_size, 1)
  max_size         = try(each.value.max_size, 1)
  desired_capacity = try(each.value.min_size, 1)

  image_id      = "ami-0d97d7f07b25dd693"
  instance_type = "t2.micro"

  vpc_zone_identifier = each.value.subnets

  create                      = true
  create_iam_instance_profile = true
  security_groups             = try(each.value.security_groups, [])

  iam_role_name        = "${each.value.instance_name}-role"
  iam_role_description = "IAM role for EC2 instance ${local.name_prefix}${each.key}"
  iam_role_policies = merge(
    { AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" },
    { CloudWatchAgentServerPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy" }
  )

  traffic_source_attachments = {
    webservers = {
      traffic_source_identifier = module.alb.target_groups["webservers"].arn
    }
  }


  scaling_policies = {
    avg-cpu-policy-greater-than-50 = {
      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 1200
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 50.0
      }
    },
    predictive-scaling = {
      policy_type = "PredictiveScaling"
      predictive_scaling_configuration = {
        mode                         = "ForecastAndScale"
        scheduling_buffer_time       = 10
        max_capacity_breach_behavior = "IncreaseMaxCapacity"
        max_capacity_buffer          = 10
        metric_specification = {
          target_value = 32
          predefined_scaling_metric_specification = {
            predefined_metric_type = "ASGAverageCPUUtilization"
            resource_label         = "testLabel"
          }
          predefined_load_metric_specification = {
            predefined_metric_type = "ASGTotalCPUUtilization"
            resource_label         = "testLabel"
          }
        }
      }
    }
  }


  user_data = base64encode(each.value.user_data)

  tags = local.default_tags
}


module "instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.4"

  for_each = local.instances

  name = each.value.instance_name

  ami           = "ami-0d97d7f07b25dd693"
  instance_type = "t2.micro"
  tags          = local.default_tags

  create                      = true
  create_iam_instance_profile = true
  create_security_group       = try(each.value.create_security_group, false)
  associate_public_ip_address = try(each.value.associate_public_ip_address, false)

  subnet_id = each.value.subnet_id

  vpc_security_group_ids       = try(each.value.security_groups, [])
  security_group_ingress_rules = try(each.value.ingress_rules, {})

  root_block_device = {
    encrypted  = true
    type       = "gp3"
    throughput = 200
    size       = 50
  }

  iam_role_description = "IAM role for EC2 instance ${local.name_prefix}${each.key}"
  iam_role_policies = merge(
    { AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" },
    { CloudWatchAgentServerPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy" }
  )

  user_data                   = try(each.value.user_data, "")
  user_data_replace_on_change = true
}
