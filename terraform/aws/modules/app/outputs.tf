output "app_url" {
  description = "Instrução para obter a URL pública da aplicação via DNS do LoadBalancer"
  value       = "Execute: kubectl get svc paybr-api-svc -n rm562093 -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "namespace" {
  description = "Namespace Kubernetes onde a aplicação PayBR foi implantada"
  value       = kubernetes_namespace.rm562093.metadata[0].name
}
