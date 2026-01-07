output "alb_dns" {
  description = "DNS name of the ALB to access the app"
  value       = aws_lb.prod_alb.dns_name
}

output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = aws_db_instance.prod_mysql.endpoint
}

output "bastion_public_ip" {
  description = "Public IP of Bastion Host for SSH"
  value       = aws_instance.bastion.public_ip
}

output "s3_bucket_name" {
  description = "S3 bucket for static assets"
  value       = aws_s3_bucket.static_assets.bucket
}