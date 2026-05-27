variable "rede_cidr" {
  description = "CIDR block da VPC principal"
  type        = string
}

variable "subnet_cidr_1a" {
  description = "CIDR block da subnet pública na AZ us-east-1a"
  type        = string
}

variable "subnet_cidr_1b" {
  description = "CIDR block da subnet pública na AZ us-east-1b"
  type        = string
}

variable "nome_cluster" {
  description = "Nome do cluster EKS (usado nas tags de descoberta do Kubernetes)"
  type        = string
}
