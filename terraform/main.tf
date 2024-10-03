provider "aws" {
    region = "us-west-2"
}
terraform {
  backend "s3" {
    bucket         = "terraform-state-myproject-123456"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"  # The DynamoDB table for state locking
    encrypt        = true                 # Enable server-side encryption
  }
}


data "aws_vpc" "default" {
  id = "vpc-097a52b71ad705eb8"
}


data "aws_subnet" "default" {
  vpc_id = data.aws_vpc.default.id
}


resource "aws_security_group" "allow_ssh_http" {
    vpc_id      = data.aws_vpc.default.id
    name          = "allow_ssh"
    description   = "allow ssh and http access"

    ingress {
        from_port   = 22
        to_port     = 22
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

resource "aws_instance" "monitoring" {
    ami           =  "ami-08eb150f611ca277f"
    instance_type =  "t2.micro"
    security_groups = [aws_security_group.allow_ssh_http.name]

    tags = {
        Name = "monitoring-instance"
    }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "postgres"
  instance_class       = "db.t2.micro"
  db_name                 = "mydb"
  username             = "admin"
  password             = "password"
  publicly_accessible  = true
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  db_subnet_group_name = aws_db_subnet_group.default.name  # Use the subnet group
}


resource "aws_subnet" "subnet_a" {
  vpc_id     = data.aws_vpc.default.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"  
}

resource "aws_subnet" "subnet_b" {
  vpc_id     = data.aws_vpc.default.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"  
}

resource "aws_db_subnet_group" "default" {
  name       = "my_db_subnet_group"
  subnet_ids = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]  # Reference both subnets
  tags       = {
    Name = "my_db_subnet_group"
  }
}



resource "aws_s3_bucket" "mybucket" {
    bucket = "mybucket"
}

resource "aws_s3_bucket_acl" "mybucket_acl" {
    bucket = aws_s3_bucket.mybucket.id
    acl    = "private"
}


resource "aws_lambda_function" "my_lambda" {
  function_name      = "myLambdaFunction"
  role               = aws_iam_role.lambda_exec.arn
  handler            = "index.handler"
  runtime            = "nodejs12.x"
  filename           = "lambda_function.zip"
  source_code_hash   = filebase64sha256("lambda_function.zip")
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

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
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/myLambdaFunction"
  retention_in_days = 14
}
