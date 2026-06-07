resource "azurerm_storage_container" "main" {
  name                  = "webcontent"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}
