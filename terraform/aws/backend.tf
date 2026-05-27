terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }

  backend "s3" {
    bucket       = "fiap-tfstate-rm562093"
    key          = "aws/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
