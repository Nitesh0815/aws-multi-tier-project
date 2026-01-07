# Override defaults here (remove or comment out if not needed)

region = "us-east-1" # Change to your preferred region, e.g., "us-west-2"

instance_type = "t2.micro" # Keep for free tier, or change to "t3.micro"

db_instance_class = "db.t3.micro" # Keep for free tier

my_ip = "103.62.93.203/32" # Replace with your public IP (e.g., "203.0.113.0/32") for SSH access

key_name = "CICD-Pipeline-Key" # Ensure this SSH key pair exists in your AWS account

s3_bucket_name = "s3-bucket-project-suppoer-2024-9988" # Replace <unique-suffix> with a unique string (e.g., "myproject123") to avoid bucket name conflicts

# Optional: Uncomment and set if you want to override others
# db_username = "admin"
# db_password = "SecurePass123!"  # Use a strong password; consider Secrets Manager for production