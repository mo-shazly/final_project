
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-west-2"
}


variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}


variable "public_subnet_a_cidr" {
  description = "CIDR block for public subnet A"
  type        = string
  default     = "10.0.1.0/24"
}


variable "public_subnet_b_cidr" {
  description = "CIDR block for public subnet B"
  type        = string
  default     = "10.0.2.0/24"
}


variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-04dd23e62ed049936"  # Example AMI for Amazon Linux 2 in us-west-2
}


variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}


variable "db_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "mydb"
}


variable "db_username" {
  description = "PostgreSQL database username"
  type        = string
  default     = "dbadmin"
}


variable "db_password" {
  description = "PostgreSQL database password"
  type        = string
  sensitive   = true
}


variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "mybucket1-shazly"
}


variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "myLambdaFunction1"
}


variable "lambda_runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "nodejs18.x"
}
