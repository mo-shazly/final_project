provider "aws" {
  region = var.aws_region
}


resource "aws_vpc" "custom_vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true  
  enable_dns_hostnames = true 

  tags = {
    Name = "custom_vpc"
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "custom_internet_gateway"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public_rt"
  }
}


resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = var.public_subnet_a_cidr
  availability_zone = "us-west-2a"

  tags = {
    Name = "public_subnet_a"
  }
}


resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = var.public_subnet_b_cidr
  availability_zone = "us-west-2b"

  tags = {
    Name = "public_subnet_b"
  }
}


resource "aws_route_table_association" "subnet_a_association" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_route_table_association" "subnet_b_association" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_security_group" "allow_ssh_http" {
  vpc_id      = aws_vpc.custom_vpc.id
  name        = "allow_ssh_http"
  description = "Allow SSH, HTTP, and Postgres access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }
}


resource "aws_instance" "monitoring" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet_a.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  associate_public_ip_address = true

  tags = {
    Name = "monitoring-instance"
  }
}


resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "my_db_subnet_group"
  subnet_ids = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  tags = {
    Name = "my_db_subnet_group"
  }
}

resource "aws_db_instance" "postgres" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t3.micro"
  db_name                = var.db_name
  username               = "dbadmin"        
  password               = var.db_password
  publicly_accessible    = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name

  tags = {
    Name = "my_postgres_db"
  }
}


# S3 Bucket
resource "aws_s3_bucket" "mybucket1-shazly" {
  bucket = "mybucket1-shazly"

  tags = {
    Name = "My S3 Bucket"
  }
}

# Lambda IAM Role
resource "aws_iam_role" "lambda_exec2" {
  name = "serverless_lambda2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "LambdaExecutionRole"
  }
}


resource "aws_lambda_function" "my_lambda2" {
  function_name      = "myLambdaFunction1"
  role               = aws_iam_role.lambda_exec2.arn
  handler            = "index.handler"
  runtime            = "nodejs18.x"
  filename           = "lambda_function1.zip"
  source_code_hash   = filebase64sha256("lambda_function1.zip")

  tags = {
    Name = "My Lambda Function"
  }
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_log_group1" {
  count             = length(data.aws_cloudwatch_log_group.existing_log_group) == 0 ? 1 : 0
  name              = "/aws/lambda/myLambdaFunction1"
  retention_in_days = 14

  tags = {
    Name = "LambdaLogGroup"
  }
}

data "aws_cloudwatch_log_group" "existing_log_group" {
  name = "/aws/lambda/myLambdaFunction"
}
