variable "nome_cluster" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "versao_k8s" {
  description = "Versão do Kubernetes para o cluster EKS"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde o cluster EKS será provisionado"
  type        = string
}

variable "subnet_ids" {
  description = "Lista de IDs das subnets para o cluster EKS e node group"
  type        = list(string)
}

variable "tipo_instancia" {
  description = "Tipo de instância EC2 para os nós do cluster EKS"
  type        = string
}

variable "regiao" {
  description = "Região AWS onde o cluster EKS está provisionado"
  type        = string
}
