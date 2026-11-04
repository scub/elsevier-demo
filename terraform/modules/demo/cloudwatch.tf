module "metric_alarm_cpu" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 6.0"

  alarm_name          = "[${local.name_prefix}_CPUAlarm] Webserver ASG Utilization"
  alarm_description   = ""
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 70
  period              = 60
  unit                = "Count"

  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"
  statistic   = "Maximum"

  dimensions = {
    AutoScalingGroupName = module.autoscaling["webserver"].autoscaling_group_name
  }

  alarm_actions = [module.alerting_sns_topic.topic_arn]
}

module "alerting_sns_topic" {
  source  = "terraform-aws-modules/sns/aws"
  version = "~> 7.2"

  name = "webserver_alerting_topic"

  subscriptions = {
    email = {
      protocol = "email"
      endpoint = var.alerting_email
    }
  }
}