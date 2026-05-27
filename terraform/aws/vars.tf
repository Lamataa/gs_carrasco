variable "regiao" {
  description = "Região AWS onde os recursos serão provisionados"
  type        = string
  default     = "us-east-1"
}

variable "nome_cluster" {
  description = "Nome do cluster EKS"
  type        = string
  default     = "fiap-eks-rm562093"
}

variable "versao_k8s" {
  description = "Versão do Kubernetes para o cluster EKS"
  type        = string
  default     = "1.31"
}

variable "rede_cidr" {
  description = "CIDR block da VPC principal"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_1a" {
  description = "CIDR block da subnet pública na AZ us-east-1a"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_cidr_1b" {
  description = "CIDR block da subnet pública na AZ us-east-1b"
  type        = string
  default     = "10.0.2.0/24"
}

variable "tipo_instancia" {
  description = "Tipo de instância EC2 para os nós do cluster EKS"
  type        = string
  default     = "t3.medium"
}
