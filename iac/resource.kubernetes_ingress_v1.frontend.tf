resource "kubernetes_ingress_v1" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace_v1.main.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "cert-manager.io/issuer"      = kubernetes_manifest.letsencrypt_staging.manifest.metadata.name
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts = [
        "superfactorymanager.ca",
        "www.superfactorymanager.ca",
      ]
      secret_name = "sfm-website-tls"
    }

    rule {
      host = "superfactorymanager.ca"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service_v1.frontend.metadata[0].name

              port {
                number = 80
              }
            }
          }
        }
      }
    }

    rule {
      host = "www.superfactorymanager.ca"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service_v1.frontend.metadata[0].name

              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
