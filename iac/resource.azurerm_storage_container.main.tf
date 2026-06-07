resource "azurerm_storage_container" "main" {
  storage_account_id    = azurerm_storage_account.main.id
  name                  = "webcontent"
  container_access_type = "private"
}
