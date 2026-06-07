resource "kubernetes_manifest" "letsencrypt_prod" {
  depends_on = [
    azurerm_role_assignment.cert_manager_dns,
  ]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name      = "letsencrypt-prod"
      namespace = kubernetes_namespace.main.metadata[0].name
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = "TeamDman9201@gmail.com"
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [{
          dns01 = {
            azureDNS = {
              subscriptionID    = "6cb7032f-2437-4f5e-91e8-676cb67e5444"
              resourceGroupName = azurerm_resource_group.main.name
              hostedZoneName    = azurerm_dns_zone.main.name
              environment       = "AzurePublicCloud"
              managedIdentity = {
                clientID = azurerm_user_assigned_identity.cert_manager_dns.client_id
              }
            }
          }
        }]
      }
    }
  }
}
