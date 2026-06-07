resource "azurerm_dns_a_record" "www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 60
  records = [
    data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].ip,
  ]
}
