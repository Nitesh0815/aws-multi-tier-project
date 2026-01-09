# AWS Multi-Tier Architecture using Terraform

## Overview
This project demonstrates a production-style AWS multi-tier architecture fully provisioned using **Terraform (Infrastructure as Code)**. The goal of this project is to showcase real-world cloud and DevOps skills suitable for **entry-level Cloud Engineer / DevOps Engineer roles**.

The infrastructure is designed with security, scalability, and high availability in mind, following AWS best practices.

---

## Architecture Summary

The setup includes:

- Separate **Production** and **Management** VPCs
- Public and private subnets across multiple Availability Zones
- Internet Gateway and NAT Gateways
- Bastion Host for secure SSH access
- Application Load Balancer (ALB)
- Auto Scaling Group for application instances
- Multi-AZ RDS MySQL database
- IAM roles and instance profiles
- S3 bucket for static assets
- CloudWatch monitoring and SNS alerts

---

## AWS Services Used

- Amazon VPC
- EC2
- Application Load Balancer
- Auto Scaling Group
- RDS (MySQL, Multi-AZ)
- S3
- IAM
- CloudWatch
- SNS
- NAT Gateway

---

## Project Structure

```text
.
├── main.tf
├── variables.tf
├── providers.tf
├── outputs.tf
├── terraform.tfvars
├── sample.jpg
└── README.md
```

---

## How It Works

1. Terraform creates isolated VPCs for production and management.
2. Public subnets host the ALB and NAT Gateways.
3. Private subnets host application instances and RDS.
4. Bastion host in the management VPC provides controlled SSH access.
5. Application traffic flows through the ALB to EC2 instances in an Auto Scaling Group.
6. EC2 instances connect securely to RDS MySQL.
7. Static assets are served from S3.
8. CloudWatch monitors CPU usage and triggers SNS alerts.

---

## Prerequisites

- AWS account
- Terraform v1.5+ installed
- AWS CLI configured (`aws configure`)
- Existing EC2 Key Pair
- Public IP address for SSH access

---

## Deployment Steps

```bash
terraform init
terraform plan
terraform apply
```

Confirm with `yes` when prompted.

---

## Accessing the Application

After successful deployment, Terraform outputs useful values:

- **ALB DNS Name** – Open in a browser to access the web application
- **Bastion Public IP** – Use for SSH access
- **RDS Endpoint** – Used internally by the application
- **S3 Bucket Name** – Stores static assets

Example:

```bash
terraform output alb_dns
```

---

## Security Highlights

- No direct public access to application EC2 instances
- SSH access restricted via Bastion Host and IP whitelisting
- Security groups follow least privilege principle
- Database accessible only from application layer

---

## Monitoring & Alerts

- CloudWatch alarm monitors EC2 CPU utilization
- SNS sends email alerts when thresholds are breached

---

## Cleanup

To avoid AWS charges:

```bash
terraform destroy
```

---

## Why This Project

This project was built to gain **hands-on experience with real AWS infrastructure**, focusing on:

- Infrastructure as Code
- High availability and scalability
- Secure network design
- Production-style architecture

It is intended as a **portfolio project** for cloud and DevOps roles.

---

## Future Improvements

- CI/CD pipeline using GitHub Actions or Jenkins
- HTTPS with ACM and Route 53
- Secrets management using AWS Secrets Manager
- Containerized application (Docker + ECS/EKS)

---

## Author

**Nitesh Kumar**

GitHub: https://github.com/Nitesh0815
