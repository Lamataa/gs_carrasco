# ─── Namespace ───────────────────────────────────────────────────────────────

resource "kubernetes_namespace" "rm562093" {
  metadata {
    name = "rm562093"

    labels = {
      aluno   = "rm562093"
      projeto = "fiap-multicloud"
      lab     = "kubernetes"
    }
  }
}

# ─── ConfigMap ───────────────────────────────────────────────────────────────

resource "kubernetes_config_map" "paybr_config" {
  metadata {
    name      = "paybr-config"
    namespace = kubernetes_namespace.rm562093.metadata[0].name

    labels = {
      aluno   = "rm562093"
      projeto = "fiap-multicloud"
      lab     = "kubernetes"
    }
  }

  data = {
    CLOUD_PROVIDER = "AWS"
    REGION         = "us-east-1"
    CLUSTER_TYPE   = "EKS Managed"
    DB_HOST        = "rds.internal"
    FEATURE_FLAGS  = "fraud-detection=true,auth=true"
  }
}

# ─── Deployment ──────────────────────────────────────────────────────────────

resource "kubernetes_deployment" "paybr_api" {
  metadata {
    name      = "paybr-api"
    namespace = kubernetes_namespace.rm562093.metadata[0].name

    labels = {
      app     = "paybr-api"
      cloud   = "eks"
      aluno   = "rm562093"
      projeto = "fiap-multicloud"
      lab     = "kubernetes"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "paybr-api"
      }
    }

    template {
      metadata {
        labels = {
          app   = "paybr-api"
          cloud = "eks"
          aluno = "rm562093"
        }
      }

      spec {
        init_container {
          name  = "init-html"
          image = "busybox"

          command = [
            "sh", "-c",
            <<-EOT
            cat > /html/index.html <<'EOF'
            <!DOCTYPE html>
            <html>
            <head><title>PayBR - EKS</title>
            <style>
              body{font-family:Arial;background:#FF9900;color:white;
                   display:flex;justify-content:center;align-items:center;height:100vh;margin:0;}
              .card{background:rgba(0,0,0,0.15);border-radius:12px;padding:40px;
                    text-align:center;max-width:400px;}
              h1{font-size:2em;margin-bottom:8px;}
              .badge{background:#232F3E;padding:6px 16px;border-radius:20px;font-size:0.9em;}
            </style>
            </head>
            <body>
              <div class="card">
                <h1>PayBR Fintech</h1>
                <p>Cluster: fiap-eks-rm562093</p>
                <p>Cloud: <span class="badge">AWS / EKS</span></p>
                <p>Status: Operacional</p>
                <p>Aluno: Gabriel Lamata — rm562093</p>
              </div>
            </body>
            </html>
            EOF
            EOT
          ]

          volume_mount {
            name       = "html"
            mount_path = "/html"
          }
        }

        container {
          name  = "paybr-api"
          image = "nginx:1.25-alpine"

          port {
            container_port = 80
          }

          env {
            name  = "CLOUD_PROVIDER"
            value = "AWS / EKS"
          }

          env {
            name  = "CLUSTER_NAME"
            value = "fiap-eks-rm562093"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "250m"
              memory = "128Mi"
            }
          }

          volume_mount {
            name       = "html"
            mount_path = "/usr/share/nginx/html"
          }
        }

        volume {
          name = "html"
          empty_dir {}
        }
      }
    }
  }
}

# ─── Service ─────────────────────────────────────────────────────────────────

resource "kubernetes_service" "paybr_api_svc" {
  metadata {
    name      = "paybr-api-svc"
    namespace = kubernetes_namespace.rm562093.metadata[0].name

    labels = {
      aluno   = "rm562093"
      projeto = "fiap-multicloud"
      lab     = "kubernetes"
    }
  }

  spec {
    type = "LoadBalancer"

    selector = {
      app = "paybr-api"
    }

    port {
      port        = 80
      target_port = 80
    }
  }
}