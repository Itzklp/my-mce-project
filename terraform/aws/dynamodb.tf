resource "aws_dynamodb_table" "cart" {
  name           = "mce-cart-${var.project_suffix}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "userId"
  attribute {
    name = "userId"
    type = "S"
  }
}
