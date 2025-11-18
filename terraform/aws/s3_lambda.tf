resource "aws_s3_bucket" "uploads" {
  bucket = "mce-uploads-${var.project_suffix}"
}

resource "aws_s3_bucket_ownership_controls" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket                  = aws_s3_bucket.uploads.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lambda inline policy to access S3 is attached here
resource "aws_iam_role_policy" "lambda_s3_access" {
  name = "lambda-s3-access-${var.project_suffix}"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"],
      Resource = [
        aws_s3_bucket.uploads.arn,
        "${aws_s3_bucket.uploads.arn}/*"
      ]
    }]
  })
}

resource "aws_lambda_function" "image_processor" {
  function_name = "mce-image-processor-${var.project_suffix}"
  runtime       = "python3.10"
  handler       = "main.handler"
  role          = aws_iam_role.lambda_role.arn

  filename         = "${path.module}/lambda/image_processor.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/image_processor.zip")

  depends_on = [
    aws_iam_role.lambda_role,
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy.lambda_s3_access
  ]
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_processor.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.uploads.arn
}

resource "aws_s3_bucket_notification" "uploads_notification" {
  bucket = aws_s3_bucket.uploads.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processor.arn
    events              = ["s3:ObjectCreated:*"]
    # optional filter; remove or change as needed
    # filter_suffix = ".jpg"
  }

  depends_on = [
    aws_lambda_permission.allow_s3,
    aws_s3_bucket_ownership_controls.uploads
  ]
}


