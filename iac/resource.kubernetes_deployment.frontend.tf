resource "kubernetes_deployment_v1" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace_v1.main.metadata[0].name
    labels    = local.frontend_selector
  }

  spec {
    replicas = 1

    selector {
      match_labels = local.frontend_selector
    }

    template {
      metadata {
        labels = local.frontend_selector
      }

      spec {
        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        container {
          name  = "nginx"
          image = "nginx:1.27-alpine"

          port {
            container_port = 80
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }

            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          volume_mount {
            name       = "nginx-conf"
            mount_path = "/etc/nginx/nginx.conf"
            sub_path   = "nginx.conf"
          }

          volume_mount {
            name       = "site-content"
            mount_path = "/usr/share/nginx/html"
            read_only  = true
          }
        }

        volume {
          name = "nginx-conf"

          config_map {
            name = kubernetes_config_map_v1.nginx_conf.metadata[0].name
          }
        }

        volume {
          name = "site-content"

          csi {
            driver = "blob.csi.azure.com"
            volume_attributes = {
              containerName = azurerm_storage_container.main.name
              secretName    = kubernetes_secret_v1.storage_account.metadata[0].name
              mountOptions  = "-o allow_other --file-cache-timeout-in-seconds=120"
            }
          }
        }
      }
    }
  }
}
