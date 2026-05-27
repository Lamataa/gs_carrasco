provider "aws" {
  region = var.regiao
}

# O provider Kubernetes usa try() para evitar erro no primeiro apply,
# quando o cluster ainda não existe e o endpoint seria vazio.
# Fluxo recomendado: terraform apply -target=module.eks → terraform apply
provider "kubernetes" {
  host                   = try(module.eks.cluster_endpoint, "")
  cluster_ca_certificate = try(base64decode(module.eks.cluster_ca), "")

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.nome_cluster, "--region", var.regiao]
  }
}
