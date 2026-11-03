locals {
  instances = {
    webserver = {
      instance_name         = "${local.name_prefix}web"
      create_security_group = false
      security_groups       = [module.web_sg.id]
      subnet_id             = element(module.vpc.private_subnets, 0)
      user_data             = file("${path.module}/files/webserver.userdata.sh")
    },
    bastion = {
      instance_name               = "${local.name_prefix}bastion"
      associate_public_ip_address = true
      create_security_group       = true
      subnet_id                   = element(module.vpc.public_subnets, 0)
      user_data                   = file("${path.module}/files/bastion.userdata.sh")
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
    allow-bastion-http = {
      from_port   = "8080"
      to_port     = "8080"
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
      from_port   = "0"
      to_port     = "65535"
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

output "public_ip" {
  value = {
    for k, v in local.instances : k => module.instances[k].public_ip
  }
}

output "private_ip" {
  value = {
    for k, v in local.instances : k => module.instances[k].private_ip
  }
}