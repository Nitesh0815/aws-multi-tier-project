############################################
# Terraform Variable Overrides
# Modify only if needed
############################################

# AWS region for all resources
region = "us-east-1"

# EC2 instance type (free tier friendly)
instance_type = "t2.micro"

# RDS instance class (free tier friendly)
db_instance_class = "db.t3.micro"

# Your public IP for SSH access to Bastion
# Update this if your ISP IP changes
my_ip = "103.62.93.203/32"

# Existing EC2 key pair name
key_name = "CICD-Pipeline-Key"

# S3 bucket for static assets
# Must be globally unique
s3_bucket_name = "s3-bucket-project-suppoer-2024-9988"

############################################
# Optional overrides
############################################

# db_username = "admin"
# db_password = "SecurePass123!"
