
provider "github" {
  token = var.github_token
  owner = var.repository_owner
}

# current account
data "aws_caller_identity" "current" {}


# create USER on AWS
# @todo config OIDC
resource "aws_iam_user" "cicd_user" {
  name = "${var.prefix}-cicd-user"
}

resource "aws_iam_user_policy" "cicd_user_policy" {
  name   = "${var.prefix}-cicd-ecr-policy"
  user   = aws_iam_user.cicd_user.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action   = [
            "ecr:GetAuthorizationToken",
            ]
            Effect   = "Allow"
            Resource = "*"
        },
        {
            Action   = [
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage"
            ]
            Effect   = "Allow"
            Resource = "arn:aws:ecr:*:*:repository/${var.prefix}*"
        },
        {
            Action   = [
            "ecs:ListTaskDefinitions",
            ]
            Effect   = "Allow"
            Resource = "*"
        },
        {
            Action   = [
            "ecs:UpdateService",
            ]
            Effect   = "Allow"
          Resource = [
            "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.prefix}",
            "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:service/${var.prefix}/*"
          ]
        }
    ]
})
}

resource "aws_iam_access_key" "cicd_user_key" {
  user    = aws_iam_user.cicd_user.name
}

# github secrets and variables
# @todo use environments (if paid github)
resource "github_actions_variable" "cicd_user_aws_access_key_id" {
  repository       = var.repository_name
  variable_name    = "AWS_ACCESS_KEY_ID"
  value            = aws_iam_access_key.cicd_user_key.id
}

resource "github_actions_secret" "cicd_user_aws_secret_access_key" {
  repository      = var.repository_name
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = aws_iam_access_key.cicd_user_key.secret
}

resource "github_actions_variable" "ecr_image" {
  repository       = var.repository_name
  variable_name    = "ECR_REPO"
  value            = var.ecr_repo
}

resource "github_actions_variable" "aws_region" {
  repository       = var.repository_name
  variable_name    = "AWS_REGION"
  value            = var.aws_region
}

resource "github_actions_variable" "ecs_cluster" {
  repository       = var.repository_name
  variable_name    = "ECS_CLUSTER"
  value            = var.cluster
}

resource "github_actions_variable" "ecs_service" {
  repository       = var.repository_name
  variable_name    = "ECS_SERVICE"
  value            = var.service
}