
provider "github" {
  token = var.github_token
  owner = var.repository_owner
}

# current account
data "aws_caller_identity" "current" {}


# OIDC
resource "aws_iam_openid_connect_provider" "github_oidc_provider" {

  url = "https://token.actions.githubusercontent.com"
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"]

  client_id_list = [
    "sts.amazonaws.com",
  ]

}

data "aws_iam_policy_document" "github_oidc_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_oidc_provider.arn]
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test     = "StringLike"
      values   = ["repo:${var.repository_owner}/*"]
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}

resource "aws_iam_role" "github_oidc_role" {
  name               = "${var.prefix}-github-oidc-role"
  assume_role_policy = data.aws_iam_policy_document.github_oidc_policy.json
}

data "aws_iam_policy_document" "github_deployment_policy" {

  statement {
    effect   = "Allow"
    actions   = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }

  statement{
    effect   = "Allow"
    actions   = [
    "ecr:BatchCheckLayerAvailability",
    "ecr:GetDownloadUrlForLayer",
    "ecr:BatchGetImage",
    "ecr:InitiateLayerUpload",
    "ecr:CompleteLayerUpload",
    "ecr:PutImage",
    "ecr:UploadLayerPart",
    ]
    resources = ["arn:aws:ecr:*:*:repository/${var.prefix}*"]
  }

  statement {
    effect   = "Allow"
    actions   = [
    "ecs:ListTaskDefinitions",
    ]
    resources = ["*"]
  }

  statement {
    effect   = "Allow"
    actions   = [
      "ecs:UpdateService",
    ]
    resources = [
    "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster}",
    "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:service/${var.cluster}/*"
    ]
  }

}

resource "aws_iam_policy" "github_deployment_policy" {
  name        = "${var.prefix}-github-deployment-policy"
  policy      = data.aws_iam_policy_document.github_deployment_policy.json
}

resource "aws_iam_role_policy_attachment" "github_deployment_rp_attachment" {
  role       = aws_iam_role.github_oidc_role.name
  policy_arn = aws_iam_policy.github_deployment_policy.arn
}

# github secrets and variables
resource "github_actions_variable" "aws_role_to_assume" {
  repository       = var.repository_name
  variable_name    = "AWS_ROLE"
  value            = aws_iam_role.github_oidc_role.arn
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