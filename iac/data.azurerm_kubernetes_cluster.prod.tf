data "azurerm_kubernetes_cluster" "prod" {
  resource_group_name = "CACN-Cluster-Benthic-PROD-RG"
  name                = "Benthic-PROD-AKS"
}
