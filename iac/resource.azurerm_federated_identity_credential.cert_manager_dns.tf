resource "azurerm_federated_identity_credential" "cert_manager_dns" {
  name      = "cert-manager"
  parent_id = azurerm_user_assigned_identity.cert_manager_dns.id
  issuer    = data.azurerm_kubernetes_cluster.prod.oidc_issuer_url
  subject   = "system:serviceaccount:cert-manager:cert-manager"
  audience  = ["api://AzureADTokenExchange"]
}
