resource "namecheap_domain_records" "main" {
  domain      = "superfactorymanager.ca"
  mode        = "OVERWRITE"
  nameservers = azurerm_dns_zone.main.name_servers
}
