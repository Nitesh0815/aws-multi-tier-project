############################################
# VPCs
############################################

# Production VPC
resource "aws_vpc" "prod" {
  cidr_block = var.vpc_cidr_prod

  tags = {
    Name = "Prod-VPC"
  }
}

# Management VPC (used for bastion)
resource "aws_vpc" "mgmt" {
  cidr_block = var.vpc_cidr_mgmt

  tags = {
    Name = "Mgmt-VPC"
  }
}

############################################
# Availability Zones
############################################

# Fetch available AZs dynamically
data "aws_availability_zones" "available" {
  state = "available"
}

############################################
# Subnets
############################################

# Public subnets for Prod VPC (ALB, NAT)
resource "aws_subnet" "prod_public" {
  count             = length(var.public_subnets_prod)
  vpc_id            = aws_vpc.prod.id
  cidr_block        = var.public_subnets_prod[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "Prod-Public-${count.index + 1}${data.aws_availability_zones.available.names[count.index]}"
  }
}

# Private subnets for application & RDS
resource "aws_subnet" "prod_private" {
  count             = length(var.private_subnets_prod)
  vpc_id            = aws_vpc.prod.id
  cidr_block        = var.private_subnets_prod[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "Prod-Private-${count.index + 1}${data.aws_availability_zones.available.names[count.index]}"
  }
}

# Single public subnet in Mgmt VPC for bastion
resource "aws_subnet" "mgmt_public" {
  vpc_id            = aws_vpc.mgmt.id
  cidr_block        = var.public_subnet_mgmt
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Mgmt-Public-1A"
  }
}

############################################
# Internet & NAT Gateways
############################################

# Internet Gateway for Prod VPC
resource "aws_internet_gateway" "prod" {
  vpc_id = aws_vpc.prod.id

  tags = {
    Name = "Prod-IGW"
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = 2
}

# NAT Gateways (one per public subnet)
resource "aws_nat_gateway" "prod" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.prod_public[count.index].id

  tags = {
    Name = "Prod-NAT-${count.index + 1}A"
  }
}

############################################
# Route Tables
############################################

# Public route table
resource "aws_route_table" "prod_public" {
  vpc_id = aws_vpc.prod.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod.id
  }

  tags = {
    Name = "Prod-Public-RT"
  }
}

resource "aws_route_table_association" "prod_public" {
  count          = length(aws_subnet.prod_public)
  subnet_id      = aws_subnet.prod_public[count.index].id
  route_table_id = aws_route_table.prod_public.id
}

# Private route tables (mapped to NATs)
resource "aws_route_table" "prod_private" {
  count  = 2
  vpc_id = aws_vpc.prod.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.prod[count.index].id
  }

  tags = {
    Name = "Prod-Private-RT-${count.index + 1}"
  }
}

resource "aws_route_table_association" "prod_private" {
  count          = length(aws_subnet.prod_private)
  subnet_id      = aws_subnet.prod_private[count.index].id
  route_table_id = aws_route_table.prod_private[count.index].id
}

############################################
# Security Groups
############################################

# Bastion SG (SSH only from my IP)
resource "aws_security_group" "bastion" {
  name   = "Bastion-SG"
  vpc_id = aws_vpc.mgmt.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Application EC2 SG
resource "aws_security_group" "app" {
  name   = "App-SG"
  vpc_id = aws_vpc.prod.id

  # HTTP traffic only from ALB
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # SSH access from Mgmt VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_mgmt]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ALB SG (public HTTP)
resource "aws_security_group" "alb" {
  name   = "ALB-SG"
  vpc_id = aws_vpc.prod.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS SG (MySQL only from app layer)
resource "aws_security_group" "rds" {
  name   = "RDS-SG"
  vpc_id = aws_vpc.prod.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
}

############################################
# Bastion Host
############################################

resource "aws_instance" "bastion" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2 (us-east-1)
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.mgmt_public.id
  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = {
    Name = "Bastion-Host"
  }
}

############################################
# RDS (MySQL - Multi AZ)
############################################

resource "aws_db_subnet_group" "prod" {
  name       = "prod-db-subnet-group"
  subnet_ids = aws_subnet.prod_private[*].id
}

resource "aws_db_instance" "prod_mysql" {
  identifier               = "prod-mysql"
  engine                   = "mysql"
  engine_version           = "8.0"
  instance_class           = var.db_instance_class
  allocated_storage        = 20
  username                 = var.db_username
  password                 = var.db_password
  db_subnet_group_name     = aws_db_subnet_group.prod.name
  vpc_security_group_ids   = [aws_security_group.rds.id]
  multi_az                 = true
  backup_retention_period  = 7
  skip_final_snapshot      = true

  tags = {
    Name = "Prod-MySQL"
  }
}

############################################
# Launch Template & IAM
############################################

resource "aws_launch_template" "app" {
  name                   = "App-Launch-Template"
  image_id               = "ami-0c02fb55956c7d316"
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd mysql
    systemctl start httpd
    systemctl enable httpd

    cat > /var/www/html/index.html <<INNEREOF
    <html>
      <body>
        <h1>Hello from AWS Multi-Tier App!</h1>
        <p>
          Static asset from S3:
          <img src="https://${var.s3_bucket_name}.s3.amazonaws.com/sample.jpg">
        </p>
        <p>
          RDS Test:
          $(mysql -h ${aws_db_instance.prod_mysql.endpoint} -u ${var.db_username} -p${var.db_password} -e "SELECT 'Database Connected!';" 2>/dev/null | tail -1)
        </p>
      </body>
    </html>
    INNEREOF
  EOF
  )

  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }
}

resource "aws_iam_role" "app" {
  name = "App-EC2-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "app" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "app" {
  name = aws_iam_role.app.name
  role = aws_iam_role.app.name
}

############################################
# Auto Scaling & Load Balancer
############################################

resource "aws_autoscaling_group" "app" {
  name = "App-ASG"

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  min_size            = 1
  max_size            = 4
  desired_capacity    = 2
  vpc_zone_identifier = aws_subnet.prod_private[*].id
  target_group_arns   = [aws_lb_target_group.app.arn]

  tag {
    key                 = "Name"
    value               = "App-Instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu" {
  name                   = "CPU-Scaling"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

resource "aws_lb" "prod_alb" {
  name               = "Prod-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.prod_public[*].id
}

resource "aws_lb_target_group" "app" {
  name     = "App-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.prod.id

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.prod_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

############################################
# S3 Static Assets
############################################

resource "aws_s3_bucket" "static_assets" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_public_access_block" "static_assets" {
  bucket                  = aws_s3_bucket.static_assets.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_object" "sample" {
  bucket = aws_s3_bucket.static_assets.bucket
  key    = "sample.jpg"
  source = "sample.jpg"
}

############################################
# Monitoring & Alerts
############################################

resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "High-CPU-Alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
}

resource "aws_sns_topic" "alerts" {
  name = "CloudWatch-Alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "nk9910922101@gmail.com"
}
