resource "azurerm_dns_zone" "main" {
  name                = "superfactorymanager.ca"
  resource_group_name = azurerm_resource_group.main.name
}
