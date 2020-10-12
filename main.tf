# https://engineering.finleap.com/posts/2020-02-20-ecs-fargate-terraform/

resource "aws_ecs_cluster" "cluster-test" {
  name = "${var.name}-cluster-${var.environment}"
}

resource "aws_ecs_task_definition" "task-test" {
  family                   = "service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{
   name        = "${var.name}-container-${var.environment}"
   image       = "${var.container_image}:latest"
   essential   = true
   environment = [] # "test"
   portMappings = [{
     protocol      = "tcp"
     containerPort = var.container_port
     hostPort      = var.container_port
   }]
 }])
}

# DynamoDB access role
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name}-ecsTaskRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

# resource "aws_iam_policy" "dynamodb" {
#   name        = "${var.name}-task-policy-dynamodb"
#   description = "Policy that allows access to DynamoDB"
#
#  policy = <<EOF
# {
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Effect": "Allow",
#            "Action": [
#                "dynamodb:CreateTable",
#                "dynamodb:UpdateTimeToLive",
#                "dynamodb:PutItem",
#                "dynamodb:DescribeTable",
#                "dynamodb:ListTables",
#                "dynamodb:DeleteItem",
#                "dynamodb:GetItem",
#                "dynamodb:Scan",
#                "dynamodb:Query",
#                "dynamodb:UpdateItem",
#                "dynamodb:UpdateTable"
#            ],
#            "Resource": "*"
#        }
#    ]
# }
# EOF
# }
#
# resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
#   role       = aws_iam_role.ecs_task_role.name
#   policy_arn = aws_iam_policy.dynamodb.arn
# }


# data "aws_iam_policy_document" "ecs_task_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRole",]
#
#     principals {
#       type        = "Service",
#       identifiers = ["ecs-tasks.amazonaws.com",]
#     }
#   }
# }
#
# resource "aws_iam_role" "instance" {
#   name               = "${var.name}-ecsTaskExecutionRole"
#   # path               = "/system/"
#   assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
# }

# Task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}-ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "service-test" {
 name                               = "${var.name}-service-${var.environment}"
 cluster                            = aws_ecs_cluster.cluster-test.id
 task_definition                    = aws_ecs_task_definition.task-test.arn
 desired_count                      = 2
 deployment_minimum_healthy_percent = 50
 deployment_maximum_percent         = 200
 launch_type                        = "FARGATE"
 scheduling_strategy                = "REPLICA"

 network_configuration {
   security_groups  = [aws_security_group.sg-ecs-tasks.name,] # var.ecs_service_security_groups
   subnets          = [for s in data.aws_subnet.subnets : s.id] # var.subnets.*.id
   assign_public_ip = false
 }

 load_balancer {
   target_group_arn = aws_alb_target_group.tgroup.arn # var.aws_alb_target_group_arn
   container_name   = "${var.name}-container-${var.environment}"
   container_port   = var.container_port
 }

 lifecycle {
   ignore_changes = [task_definition, desired_count]
 }
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.cluster-test.name}/${aws_ecs_service.service-test.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
   predefined_metric_specification {
     predefined_metric_type = "ECSServiceAverageMemoryUtilization"
   }

   target_value       = 80
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
   predefined_metric_specification {
     predefined_metric_type = "ECSServiceAverageCPUUtilization"
   }

   target_value       = 60
  }
}
