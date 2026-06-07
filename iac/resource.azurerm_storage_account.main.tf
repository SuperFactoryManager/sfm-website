resource "azurerm_storage_account" "main" {
  name                            = "sfmwebsiteprod"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  tags                            = azurerm_resource_group.main.tags
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
}
