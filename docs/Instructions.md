# Instructions

## GitHub Repository

Create a public GitHub repository to host all files and code for this exercise.
Use meaningful commit messages that clearly explain the changes made at each step.

## Infrastructure as Code (IaC)

Use Terraform to provision an AWS environment with the following:
  - An EC2 instance (t2.micro) in a custom VPC with private and public subnets.
  - A Bastion host in the public subnet for secure access to instances in private subnets.
  - A web server running on an EC2 instance in the private subnet.

Configure security groups to:

  - Allow HTTP traffic (port 80) to the web server from the Bastion host only.
  - Allow SSH access to the Bastion host from your IP.
  - Use IAM roles and policies to grant the least privilege needed for the instances.

# Web Application Deployment

  - Deploy a web application on the web server that serves a “Hello, World!” HTML page.
  - Automate the deployment of the web server and application using Terraform provisioners, cloud-init, or a configuration management tool like Ansible.

# Load Balancing and Auto Scaling:

  - Add an Application Load Balancer (ALB) in front of the web server.
  - Implement an Auto Scaling Group (ASG) with a minimum of 1 instance and a maximum of 3 instances, triggered by CPU usage.

# Monitoring and Alerts:

Set up CloudWatch monitoring to:

  - Track the CPU and memory usage of the web servers.
  - Enable CloudWatch Alarms to notify you if the CPU usage exceeds 70%.
  - Configure an alarm notification via SNS (email or topic subscription).

## Cost Optimisation

Ensure the architecture fits within the AWS Free Tier wherever possible.
Document any considerations taken to reduce costs or remain within limits.

## CI/CD Pipeline

Implement a GitHub Actions or Jenkins pipeline to:

  - Validate Terraform code using terraform fmt and terraform validate.
  - Plan and apply Terraform code (manual approval step for apply).
  - Automate testing to ensure the web application is accessible via the ALB.

## Documentation

Create a detailed README.md in your repository, including:

  - Steps to deploy the infrastructure.
  - Details on how to test the deployed solution.
  - Any assumptions or prerequisites.
  - Instructions to clean up resources to avoid unnecessary costs.


# Optional (Bonus Points):

  - Containerisation: Package the web application in a Docker container and deploy it using Amazon ECS or EKS.
  - Infrastructure Testing: Write automated tests using tools like Terratest or AWS CLI scripts to validate the deployment.
  - Secret Management: Use AWS Secrets Manager to securely store and retrieve sensitive information (e.g., web server credentials).
