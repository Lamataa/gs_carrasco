output "vpc_id" {
  description = "ID da VPC criada para o cluster EKS"
  value       = module.rede.vpc_id
}

output "cluster_name" {
  description = "Nome do cluster EKS provisionado"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint de acesso ao cluster EKS"
  value       = module.eks.cluster_endpoint
}

output "kubeconfig_cmd" {
  description = "Comando para configurar o kubectl com o cluster EKS"
  value       = module.eks.kubeconfig_cmd
}
