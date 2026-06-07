resource "kubernetes_namespace" "main" {
  metadata {
    name = "sfm-website"
    labels = {
      "app.kubernetes.io/name" = "sfm-website"
    }
  }
}
