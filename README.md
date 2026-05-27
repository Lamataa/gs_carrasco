# Lab 4 FIAP — Kubernetes EKS AWS

**Aluno:** Gabriel Lamata  
**RM:** rm562093  
**Disciplina:** Kubernetes Multicloud — FIAP  

Projeto Terraform para provisionamento de um cluster **Amazon EKS** na AWS, incluindo toda a infraestrutura de rede, o cluster Kubernetes gerenciado e o deploy da aplicação **PayBR Fintech**.

---

## Estrutura de Pastas

```
.
├── terraform/
│   └── aws/
│       ├── backend.tf          # Providers + backend S3
│       ├── provider.tf         # Configuração dos providers AWS e Kubernetes
│       ├── main.tf             # Chamadas dos módulos
│       ├── vars.tf             # Variáveis raiz com defaults
│       ├── outputs.tf          # Outputs principais
│       └── modules/
│           ├── rede/           # VPC, subnets, IGW, route table
│           │   ├── vpc.tf
│           │   ├── vars.tf
│           │   └── outputs.tf
│           ├── eks/            # IAM roles, cluster EKS, node group
│           │   ├── cluster.tf
│           │   ├── vars.tf
│           │   └── outputs.tf
│           └── app/            # Namespace, ConfigMap, Deployment, Service
│               ├── app.tf
│               ├── vars.tf
│               └── outputs.tf
├── .github/
│   └── workflows/
│       └── eks.yaml            # Pipeline CI/CD (fmt → validate → plan → apply)
├── .gitignore
└── README.md
```

---

## Infraestrutura Provisionada

| Recurso | Nome | Detalhes |
|---|---|---|
| VPC | `fiap-vpc-rm562093` | CIDR `10.0.0.0/16` |
| Internet Gateway | `fiap-igw-rm562093` | Associado à VPC |
| Subnet pública 1a | `fiap-subnet-pub-1a-rm562093` | `10.0.1.0/24` — `us-east-1a` |
| Subnet pública 1b | `fiap-subnet-pub-1b-rm562093` | `10.0.2.0/24` — `us-east-1b` |
| Route Table | `fiap-rt-rm562093` | Rota `0.0.0.0/0` via IGW |
| Cluster EKS | `fiap-eks-rm562093` | Kubernetes `1.31` |
| Node Group | `fiap-ng-rm562093` | `t3.medium`, 2 nós (min 1, max 3) |
| IAM Role Control Plane | `fiap-eks-role-rm562093` | `AmazonEKSClusterPolicy` |
| IAM Role Nodes | `fiap-eks-node-role-rm562093` | Worker + CNI + ECR policies |
| Namespace | `rm562093` | Namespace dedicado ao aluno |
| Deployment | `paybr-api` | `nginx:1.25-alpine`, 2 réplicas |
| Service | `paybr-api-svc` | `LoadBalancer` (NLB externo) |

---

## Pré-requisitos

- [AWS CLI](https://aws.amazon.com/cli/) instalado e configurado
- [Terraform](https://developer.hashicorp.com/terraform/install) versão `1.10+`
- [kubectl](https://kubernetes.io/docs/tasks/tools/) instalado
- Permissões AWS para criar: VPC, EKS, IAM Roles, EC2

---

## 1. Configurar Credenciais AWS

```bash
aws configure
# AWS Access Key ID: <sua-chave>
# AWS Secret Access Key: <seu-segredo>
# Default region name: us-east-1
# Default output format: json
```

Ou exportar as variáveis de ambiente:

```bash
export AWS_ACCESS_KEY_ID="sua-chave"
export AWS_SECRET_ACCESS_KEY="seu-segredo"
export AWS_DEFAULT_REGION="us-east-1"
```

---

## 2. Criar o Bucket S3 para o Backend

O bucket S3 precisa existir **antes** de rodar o Terraform:

```bash
aws s3api create-bucket \
  --bucket fiap-tfstate-rm562093 \
  --region us-east-1

# Habilitar versionamento (recomendado)
aws s3api put-bucket-versioning \
  --bucket fiap-tfstate-rm562093 \
  --versioning-configuration Status=Enabled
```

---

## 3. Inicializar e Aplicar o Terraform

> ⚠️ **Importante — apply em dois passos**  
> O provider Kubernetes tenta se conectar ao cluster durante o `plan`. Como o cluster ainda não existe no primeiro apply, é necessário rodar em **duas etapas**:

```bash
cd terraform/aws

# Inicializar — baixa providers e configura o backend S3
terraform init

# Verificar formatação
terraform fmt -check -recursive

# Validar configuração
terraform validate

# ── Passo 1: provisionar apenas a rede + cluster EKS ──────────────────────────
terraform apply -target=module.rede -target=module.eks

# Aguarde o cluster ficar ativo (10–15 minutos) e então:

# ── Passo 2: aplicar o restante (módulo app / manifests Kubernetes) ────────────
terraform apply
```

> **Tempo estimado total:** entre **12 a 18 minutos** (cluster EKS + provisionamento dos nós).

---

## 4. Configurar o kubectl

Após o `apply` concluir, configure o kubectl com o cluster:

```bash
aws eks update-kubeconfig \
  --name fiap-eks-rm562093 \
  --region us-east-1
```

Ou use o output do Terraform:

```bash
$(terraform output -raw kubeconfig_cmd)
```

---

## 5. Verificar o Deploy

```bash
# Verificar os pods da aplicação
kubectl get pods -n rm562093

# Verificar o serviço e aguardar o DNS do LoadBalancer
kubectl get svc -n rm562093

# Ver detalhes do deployment
kubectl describe deployment paybr-api -n rm562093

# Ver logs de um pod
kubectl logs -l app=paybr-api -n rm562093
```

---

## 6. Acessar a Aplicação

Aguarde o provisionamento do LoadBalancer (pode levar alguns minutos após o `apply`):

```bash
# Obter o DNS do LoadBalancer
kubectl get svc paybr-api-svc -n rm562093 \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Abra o DNS retornado no navegador — você verá a página **PayBR Fintech** com fundo laranja AWS.

---

## 7. Destruir a Infraestrutura

```bash
cd terraform/aws
terraform destroy
```

> ⚠️ **Atenção:** o `destroy` removerá **todos** os recursos AWS criados. O bucket S3 com o state não é destruído automaticamente.

---

## CI/CD — GitHub Actions

O workflow `.github/workflows/eks.yaml` executa automaticamente no push para a branch `test`:

| Job | Etapas |
|---|---|
| `eks` | fmt → init → validate → plan → apply |
| `security` | Trivy (config scan) + Checkov (terraform) |

### Secrets necessários no repositório GitHub:

| Secret | Descrição |
|---|---|
| `AWS_ACCESS_KEY_ID` | Chave de acesso AWS |
| `AWS_SECRET_ACCESS_KEY` | Chave secreta AWS |

---

## Tags nos Recursos

Todos os recursos AWS criados possuem as seguintes tags obrigatórias:

```hcl
aluno   = "rm562093"
projeto = "fiap-multicloud"
lab     = "kubernetes"
```

---

## Referências

- [Amazon EKS — Documentação oficial](https://docs.aws.amazon.com/eks/latest/userguide/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Terraform Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest)
- [FIAP — Kubernetes Multicloud Lab](https://www.fiap.com.br)
