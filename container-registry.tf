resource "aws_ecr_repository" "aws-ecr" {
  name                 = "${var.name}-${var.environment}"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_lifecycle_policy" "aws-ecr-policy" {
  repository = aws_ecr_repository.aws-ecr.name

  policy = jsonencode({
   rules = [{
     rulePriority = 1
     description  = "keep last 5 images"
     action       = {
       type = "expire"
     }
     selection     = {
       tagStatus   = "any"
       countType   = "imageCountMoreThan"
       countNumber = 5
     }
   }]
  })
}
