variable "cluster_endpoint" {
  description = "Endpoint HTTPS do cluster EKS para configuração do provider Kubernetes"
  type        = string
}

variable "cluster_ca" {
  description = "Certificado de autoridade (CA) do cluster EKS em Base64"
  type        = string
}

variable "regiao" {
  description = "Região AWS onde o cluster EKS está provisionado"
  type        = string
}

variable "nome_cluster" {
  description = "Nome do cluster EKS"
  type        = string
}
