# Improvements

The following is a list of improvements that should be made

- VPC flow logs should be enabled
- The environment is too tightly coupled, platform components are better abstracted away from the application. (eg: The ALB Target group configuration is quite brittle, and basically ties it to the existing ASG)
- ALB is exposed directly to the internet, it should be behind a WAF/CloudFlare
- Forward ALB logs to S3 with lifecycle policy
- S3 bucket logging is not enabled
- S3 buckets should require requests to use SSL
- KMS key encryption for S3 buckets 
- The CloudWatch alarms are too repetitive and should be templated; ideally converted to a module for easy re-use 
- Enable AWS EBS Snapshot Encryption
- The asset bucket lacks versioning, a real artifact storage solution should be used
- EC2's should require the use of IMDSv2
- Improve terratest coverage for module, run plan-only checks in pre-commit with full execution checks in CI
- The role used by CI can modify itself, leading to potential privilege escalations; this role should instead be vended by an administrative account rather than directly in this stack.
