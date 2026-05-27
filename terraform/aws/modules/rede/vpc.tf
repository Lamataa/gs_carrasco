resource "aws_vpc" "principal" {
  cidr_block           = var.rede_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "fiap-vpc-rm562093"
    aluno   = "rm562093"
    projeto = "fiap-multicloud"
    lab     = "kubernetes"
  }
}

resource "aws_internet_gateway" "principal" {
  vpc_id = aws_vpc.principal.id

  tags = {
    Name    = "fiap-igw-rm562093"
    aluno   = "rm562093"
    projeto = "fiap-multicloud"
    lab     = "kubernetes"
  }
}

resource "aws_subnet" "publica_1a" {
  vpc_id                  = aws_vpc.principal.id
  cidr_block              = var.subnet_cidr_1a
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                                          = "fiap-subnet-pub-1a-rm562093"
    aluno                                         = "rm562093"
    projeto                                       = "fiap-multicloud"
    lab                                           = "kubernetes"
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${var.nome_cluster}"   = "shared"
  }
}

resource "aws_subnet" "publica_1b" {
  vpc_id                  = aws_vpc.principal.id
  cidr_block              = var.subnet_cidr_1b
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name                                          = "fiap-subnet-pub-1b-rm562093"
    aluno                                         = "rm562093"
    projeto                                       = "fiap-multicloud"
    lab                                           = "kubernetes"
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${var.nome_cluster}"   = "shared"
  }
}

resource "aws_route_table" "principal" {
  vpc_id = aws_vpc.principal.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.principal.id
  }

  tags = {
    Name    = "fiap-rt-rm562093"
    aluno   = "rm562093"
    projeto = "fiap-multicloud"
    lab     = "kubernetes"
  }
}

resource "aws_route_table_association" "publica_1a" {
  subnet_id      = aws_subnet.publica_1a.id
  route_table_id = aws_route_table.principal.id
}

resource "aws_route_table_association" "publica_1b" {
  subnet_id      = aws_subnet.publica_1b.id
  route_table_id = aws_route_table.principal.id
}
