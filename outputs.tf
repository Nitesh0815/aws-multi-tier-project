############################################
# Outputs
# Useful values after terraform apply
############################################

# ALB DNS – use this in browser to access the app
output "alb_dns" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.prod_alb.dns_name
}

# RDS endpoint – used by app layer to connect to MySQL
output "rds_endpoint" {
  description = "Endpoint for the RDS MySQL database"
  value       = aws_db_instance.prod_mysql.endpoint
}

# Bastion public IP – SSH entry point
output "bastion_public_ip" {
  description = "Public IP address of the Bastion host"
  value       = aws_instance.bastion.public_ip
}

# S3 bucket name – stores static assets
output "s3_bucket_name" {
  description = "S3 bucket used for application static files"
  value       = aws_s3_bucket.static_assets.bucket
}
