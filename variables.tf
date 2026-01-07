variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr_prod" {
  description = "CIDR for Prod VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_cidr_mgmt" {
  description = "CIDR for Mgmt VPC"
  default     = "10.1.0.0/16"
}

variable "public_subnets_prod" {
  description = "Public subnets for Prod VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_prod" {
  description = "Private subnets for Prod VPC"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "public_subnet_mgmt" {
  description = "Public subnet for Mgmt VPC"
  default     = "10.1.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "db_instance_class" {
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "db_username" {
  description = "RDS username"
  default     = "admin"
}

variable "db_password" {
  description = "RDS password (use Secrets Manager in production)"
  default     = "SecurePass123!"
}

variable "my_ip" {
  description = "Your public IP for SSH access (e.g., 203.0.113.0/32)"
  default     = "<your-ip>" # Replace with your IP
}

variable "key_name" {
  description = "SSH key pair name"
  default     = "my-key-pair" # Ensure this key exists in AWS
}

variable "s3_bucket_name" {
  description = "Unique S3 bucket name"
  default     = "prod-static-assets-<unique-suffix>" # Replace <unique-suffix> with something unique
}