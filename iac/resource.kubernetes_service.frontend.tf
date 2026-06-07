resource "kubernetes_service" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.main.metadata[0].name
  }

  spec {
    selector = local.frontend_selector

    port {
      port        = 80
      target_port = 80
    }
  }
}
