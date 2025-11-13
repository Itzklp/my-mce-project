# --------------------------------------------------
# S3 Bucket and Lambda Function IAM Setup
# --------------------------------------------------

# S3 Bucket for uploads
resource "aws_s3_bucket" "uploads" {
  bucket = "mce-uploads-${var.project_suffix}"
#   acl    = "private"

  tags = {
    Project = "mce"
    Purpose = "image-uploads"
  }
}

# S3 Public Access Block (recommended)
resource "aws_s3_bucket_public_access_block" "uploads_block" {
  bucket                  = aws_s3_bucket.uploads.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "mce-lambda-role-${var.project_suffix}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Basic Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Allow Lambda to access S3 and DynamoDB
resource "aws_iam_role_policy" "lambda_s3_ddb" {
  name = "lambda-s3-ddb-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.uploads.arn,
          "${aws_s3_bucket.uploads.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ],
        Resource = "*"
      }
    ]
  })
}

# Lambda Function (add when zip ready)
# Example assumes you have image_processor.zip in same folder
resource "aws_lambda_function" "image_processor" {
  filename         = "lambda/image_processor.zip"         # path to zip file
  function_name    = "mce-image-processor-${var.project_suffix}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "image_processor.lambda_handler"
  runtime          = "python3.11"
  timeout          = 60
  memory_size      = 256

  environment {
    variables = {
      DDB_TABLE = "mce-cart-${var.project_suffix}"
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_basic]
}

# Event notification to trigger Lambda when object uploaded to S3
resource "aws_s3_bucket_notification" "uploads_notification" {
  bucket = aws_s3_bucket.uploads.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_function.image_processor]
}
