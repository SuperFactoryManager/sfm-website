resource "kubernetes_secret_v1" "storage_account" {
  metadata {
    name      = "storage-account-secret"
    namespace = kubernetes_namespace_v1.main.metadata[0].name
  }

  type = "Opaque"

  data = {
    azurestorageaccountname = azurerm_storage_account.main.name
    azurestorageaccountkey  = azurerm_storage_account.main.primary_access_key
  }
}
