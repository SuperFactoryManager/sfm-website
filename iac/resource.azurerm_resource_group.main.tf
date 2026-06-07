resource "azurerm_resource_group" "main" {
  name     = "CACN-ClusterWorkload-Benthic-sfm-website-PROD-RG"
  location = "canadacentral"
  tags = {
    environment = "Production"
    managed-by  = "OpenTofu"
    workload    = "sfm-website"
  }
}
