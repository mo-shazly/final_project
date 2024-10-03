output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.custom_vpc.id
}


output "ec2_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.monitoring.public_ip
}


output "db_endpoint" {
  description = "The endpoint of the PostgreSQL database"
  value       = aws_db_instance.postgres.endpoint
}


output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.mybucket1-shazly.bucket
}


output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.my_lambda2.arn
}


output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.my_lambda2.function_name
}
