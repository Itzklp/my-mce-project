resource "aws_ecr_repository" "frontend" {
  name = "frontend-${var.project_suffix}"
  image_scanning_configuration { scan_on_push = true }
}
# Repeat for other services or script it with for_each
