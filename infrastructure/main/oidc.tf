# Add GitHub as an Identity Provider (IdP)
# https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html
resource "aws_iam_openid_connect_provider" "gh-idp" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html
  thumbprint_list = ["959cb2b52b4ad201a593847abca32ff48f838c2e"]

}

# IAM Role that GitHub Workflows can assume through sts:AssumeRoleWithWebIdentity.
# Every time your job runs, GitHub's OIDC Provider auto-generates an OIDC token(needs to be configured). 
# This token contains multiple claims to establish a security-hardened and verifiable identity about the specific workflow that is trying to authenticate.
resource "aws_iam_role" "gh-actions" {
  name = "gh-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = "${aws_iam_openid_connect_provider.gh-idp.arn}"
      }
      Condition = {
        StringLike = {
          # Check Token's claims, if the claims match with the conditions below, a Cloud Access Token will be granted to the GH Workflow Job
          "token.actions.githubusercontent.com:sub" = "repo:carlosgit2016/argocd-deployments:*", # Examples of supported Subjects: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#example-subject-claims
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

}

resource "aws_iam_policy" "ECRAccess" {
  name        = "ecr_access"
  description = "Policy for ECR operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_access_attch" {
  role       = aws_iam_role.gh-actions.name
  policy_arn = aws_iam_policy.ECRAccess.arn
}

resource "aws_iam_role_policy_attachment" "admin_access_attch" {
  role       = aws_iam_role.gh-actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

