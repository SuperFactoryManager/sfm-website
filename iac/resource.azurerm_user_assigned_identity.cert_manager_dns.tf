resource "azurerm_user_assigned_identity" "cert_manager_dns" {
  name                = "sfm-website-cert-manager-dns"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = azurerm_resource_group.main.tags
}
