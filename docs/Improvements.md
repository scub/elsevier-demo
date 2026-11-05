# Improvements

The following is a list of improvements that should be made

- VPC flow logs should be enabled
- The environment is too tightly coupled, platform components are better abstracted away from the application. (eg: The ALB Target group configuration is quite brittle, and basically ties it to the existing ASG)
- ALB is exposed directly to the internet, it should be behind a WAF/CloudFlare
- Bastion host is exposed directly to the internet, AWS SSM or a similar solution should be leveraged to provide auditability.
- Forward ALB logs to S3
- S3 bucket logging is not enabled
- S3 buckets should require requests to use SSL
- KMS key encryption for S3 buckets 
- The CloudWatch alarms are too repetitive and should be templated; ideally converted to a module for easy re-use 
- Enable AWS EBS Snapshot Encryption
- The asset bucket is a poor stand-in for proper artifact storage, an appropriate solution should be used instead
- EC2's should require the use of IMDSv2
- Improve terratest coverage for module, converting them to terraform/tofu's native test suite where possible
- The role used by CI can modify itself, leading to potential privilege escalations; this role should instead be vended by an administrative account rather than directly in this stack.
