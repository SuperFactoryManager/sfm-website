resource "azurerm_role_assignment" "cert_manager_dns" {
  scope                = azurerm_dns_zone.main.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.cert_manager_dns.principal_id
}
