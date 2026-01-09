############################################
# Global Configuration
############################################

variable "region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

############################################
# Networking (VPC & Subnets)
############################################

variable "vpc_cidr_prod" {
  description = "CIDR block for the Production VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_cidr_mgmt" {
  description = "CIDR block for the Management VPC"
  default     = "10.1.0.0/16"
}

variable "public_subnets_prod" {
  description = "Public subnet CIDRs for the Production VPC"
  type        = list(string)
  default     = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnets_prod" {
  description = "Private subnet CIDRs for the Production VPC"
  type        = list(string)
  default     = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}

variable "public_subnet_mgmt" {
  description = "Public subnet CIDR for the Management VPC"
  default     = "10.1.1.0/24"
}

############################################
# Compute & Database
############################################

variable "instance_type" {
  description = "EC2 instance type for application and bastion hosts"
  default     = "t2.micro"
}

variable "db_instance_class" {
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "db_username" {
  description = "Master username for the RDS instance"
  default     = "admin"
}

variable "db_password" {
  description = "Master password for RDS (use Secrets Manager in production)"
  default     = "SecurePass123!"
}

############################################
# Access & Security
############################################

variable "my_ip" {
  description = "Public IP CIDR allowed for SSH access (e.g. 203.0.113.0/32)"
  default     = "<your-ip>" # Replace with your actual public IP
}

variable "key_name" {
  description = "Existing EC2 key pair name for SSH access"
  default     = "my-key-pair" # Must already exist in AWS
}

############################################
# Storage
############################################

variable "s3_bucket_name" {
  description = "Globally unique S3 bucket name for static assets"
  default     = "prod-static-assets-<unique-suffix>"
}
