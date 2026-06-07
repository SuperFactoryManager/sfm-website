resource "kubernetes_namespace_v1" "main" {
  metadata {
    name = "sfm-website"
    labels = {
      "app.kubernetes.io/name" = "sfm-website"
    }
  }
}
