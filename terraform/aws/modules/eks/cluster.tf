# ─── IAM Role — Control Plane ────────────────────────────────────────────────

resource "aws_iam_role" "eks_control_plane" {
  name = "fiap-eks-role-rm562093"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "fiap-eks-role-rm562093"
    aluno   = "rm562093"
    projeto = "fiap-multicloud"
    lab     = "kubernetes"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_control_plane.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ─── IAM Role — Nodes ────────────────────────────────────────────────────────

resource "aws_iam_role" "eks_nodes" {
  name = "fiap-eks-node-role-rm562093"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "fiap-eks-node-role-rm562093"
    aluno   = "rm562093"
    projeto = "fiap-multicloud"
    lab     = "kubernetes"
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_readonly" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# ─── Cluster EKS ─────────────────────────────────────────────────────────────

resource "aws_eks_cluster" "principal" {
  name     = var.nome_cluster
  version  = var.versao_k8s
  role_arn = aws_iam_role.eks_control_plane.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  enabled_cluster_log_types = ["api", "audit"]

  tags = {
    Name    = "fiap-eks-rm562093"
    aluno   = "rm562093"
    projeto = "fiap-multicloud"
    lab     = "kubernetes"
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# ─── Node Group ──────────────────────────────────────────────────────────────

resource "aws_eks_node_group" "principal" {
  cluster_name    = aws_eks_cluster.principal.name
  node_group_name = "fiap-ng-rm562093"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.subnet_ids
  instance_types  = [var.tipo_instancia]
  ami_type        = "AL2023_x86_64_STANDARD"
  capacity_type   = "ON_DEMAND"

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  tags = {
    Name    = "fiap-ng-rm562093"
    aluno   = "rm562093"
    projeto = "fiap-multicloud"
    lab     = "kubernetes"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_readonly,
  ]
}

