module "rede" {
  source = "./modules/rede"

  rede_cidr      = var.rede_cidr
  subnet_cidr_1a = var.subnet_cidr_1a
  subnet_cidr_1b = var.subnet_cidr_1b
  nome_cluster   = var.nome_cluster
}

module "eks" {
  source = "./modules/eks"

  depends_on = [module.rede]

  nome_cluster   = var.nome_cluster
  versao_k8s     = var.versao_k8s
  vpc_id         = module.rede.vpc_id
  subnet_ids     = module.rede.subnet_ids
  tipo_instancia = var.tipo_instancia
  regiao         = var.regiao
}

module "app" {
  source = "./modules/app"

  depends_on = [module.eks]

  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca       = module.eks.cluster_ca
  regiao           = var.regiao
  nome_cluster     = var.nome_cluster
}
