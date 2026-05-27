output "cluster_name" {
  description = "Nome do cluster EKS provisionado"
  value       = aws_eks_cluster.principal.name
}

output "cluster_endpoint" {
  description = "Endpoint HTTPS de acesso ao cluster EKS"
  value       = aws_eks_cluster.principal.endpoint
}

output "cluster_ca" {
  description = "Certificado de autoridade (CA) do cluster EKS em Base64"
  value       = aws_eks_cluster.principal.certificate_authority[0].data
}

output "kubeconfig_cmd" {
  description = "Comando completo para configurar o kubectl com o cluster EKS"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.principal.name} --region ${var.regiao}"
}
