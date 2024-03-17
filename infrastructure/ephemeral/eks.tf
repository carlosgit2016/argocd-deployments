resource "aws_iam_role" "cluster_role" {
  name = "cluster-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy_attachment" "policy_attachment" {
  for_each   = toset(["arn:aws:iam::aws:policy/AmazonEKSVPCResourceController", "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"])
  name       = "vpc-resource-controller-attachment"
  roles      = [aws_iam_role.cluster_role.name]
  policy_arn = each.value
}

resource "aws_eks_cluster" "argocd_cluster" {

  name     = "argocd_cluster"
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    subnet_ids = [for az in local.availability_zones : aws_subnet.private[az].id]
  }

  depends_on = [
    aws_iam_policy_attachment.policy_attachment
  ]

}

# Node group IAM Role and policies
resource "aws_iam_role" "node_group_role" {
  name = "eks-node-group-example"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.argocd_cluster.name
  node_group_name = "default"
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = [for az in local.availability_zones : aws_subnet.private[az].id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.argocd_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.argocd_cluster.certificate_authority[0].data
}
