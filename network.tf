data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "subnet-ids" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "subnets" {
  for_each = data.aws_subnet_ids.subnet-ids.ids
  id       = each.value
}

resource "aws_security_group" "fargate-test" {
  vpc_id = data.aws_vpc.default.id
  name   = "fargate-test"
}
