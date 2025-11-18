resource "aws_dynamodb_table" "cart" {
  name         = "mce-cart-${var.project_suffix}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "cartId"

  attribute {
    name = "cartId"
    type = "S"
  }

  tags = { Project = var.project_suffix }
}

