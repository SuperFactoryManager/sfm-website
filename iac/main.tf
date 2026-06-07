terraform {
  required_version = ">= 1.12.0"

  backend "azurerm" {
    subscription_id      = "6cb7032f-2437-4f5e-91e8-676cb67e5444"
    resource_group_name  = "CACN-Terraform-PROD-RG"
    storage_account_name = "terraformproddwvc87"
    container_name       = "statefiles"
    key                  = "sfm-website-prod.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.74.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.1.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "6cb7032f-2437-4f5e-91e8-676cb67e5444"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "Benthic-PROD-AKS"
}

data "azurerm_kubernetes_cluster" "prod" {
  resource_group_name = "CACN-Cluster-Benthic-PROD-RG"
  name                = "Benthic-PROD-AKS"
}

data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

locals {
  frontend_selector = {
    app = "sfm-website"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "CACN-ClusterWorkload-Benthic-sfm-website-PROD-RG"
  location = "canadacentral"
  tags = {
    environment = "Production"
    managed-by  = "OpenTofu"
    workload    = "sfm-website"
  }
}

resource "azurerm_dns_zone" "main" {
  name                = "superfactorymanager.ca"
  resource_group_name = azurerm_resource_group.main.name
}

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

resource "azurerm_storage_container" "main" {
  name                  = "webcontent"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_user_assigned_identity" "cert_manager_dns" {
  name                = "sfm-website-cert-manager-dns"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = azurerm_resource_group.main.tags
}

resource "azurerm_federated_identity_credential" "cert_manager_dns" {
  name                = "cert-manager"
  resource_group_name = azurerm_resource_group.main.name
  parent_id           = azurerm_user_assigned_identity.cert_manager_dns.id
  issuer              = data.azurerm_kubernetes_cluster.prod.oidc_issuer_url
  subject             = "system:serviceaccount:cert-manager:cert-manager"
  audience            = ["api://AzureADTokenExchange"]
}

resource "azurerm_role_assignment" "cert_manager_dns" {
  scope                = azurerm_dns_zone.main.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.cert_manager_dns.principal_id
}

resource "kubernetes_namespace" "main" {
  metadata {
    name = "sfm-website"
    labels = {
      "app.kubernetes.io/name" = "sfm-website"
    }
  }
}

resource "kubernetes_secret" "storage_account" {
  metadata {
    name      = "storage-account-secret"
    namespace = kubernetes_namespace.main.metadata[0].name
  }

  type = "Opaque"

  data = {
    azurestorageaccountname = azurerm_storage_account.main.name
    azurestorageaccountkey  = azurerm_storage_account.main.primary_access_key
  }
}

resource "kubernetes_config_map" "nginx_conf" {
  metadata {
    name      = "nginx-conf"
    namespace = kubernetes_namespace.main.metadata[0].name
  }

  data = {
    "nginx.conf" = <<-EOF
      worker_processes auto;
      error_log /var/log/nginx/error.log warn;
      pid /tmp/nginx.pid;

      events {
          worker_connections 1024;
      }

      http {
          include /etc/nginx/mime.types;
          default_type application/octet-stream;

          log_format main_with_host '$remote_addr - $remote_user [$time_local] "$request" '
                                    '$status $body_bytes_sent "$http_referer" "$http_user_agent" '
                                    'host: "$host"';
          access_log /var/log/nginx/access.log main_with_host;

          sendfile on;
          keepalive_timeout 65;

          include /etc/nginx/conf.d/*.conf;
      }
    EOF
  }
}

resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.main.metadata[0].name
    labels    = local.frontend_selector
  }

  spec {
    replicas = 1

    selector {
      match_labels = local.frontend_selector
    }

    template {
      metadata {
        labels = local.frontend_selector
      }

      spec {
        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        container {
          name  = "nginx"
          image = "nginx:1.27-alpine"

          port {
            container_port = 80
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }

            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          volume_mount {
            name       = "nginx-conf"
            mount_path = "/etc/nginx/nginx.conf"
            sub_path   = "nginx.conf"
          }

          volume_mount {
            name       = "site-content"
            mount_path = "/usr/share/nginx/html"
            read_only  = true
          }
        }

        volume {
          name = "nginx-conf"

          config_map {
            name = kubernetes_config_map.nginx_conf.metadata[0].name
          }
        }

        volume {
          name = "site-content"

          csi {
            driver = "blob.csi.azure.com"
            volume_attributes = {
              containerName = azurerm_storage_container.main.name
              secretName    = kubernetes_secret.storage_account.metadata[0].name
              mountOptions  = "-o allow_other --file-cache-timeout-in-seconds=120"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.main.metadata[0].name
  }

  spec {
    selector = local.frontend_selector

    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_manifest" "letsencrypt_staging" {
  depends_on = [
    azurerm_role_assignment.cert_manager_dns,
  ]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name      = "letsencrypt-staging"
      namespace = kubernetes_namespace.main.metadata[0].name
    }
    spec = {
      acme = {
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        email  = "TeamDman9201@gmail.com"
        privateKeySecretRef = {
          name = "letsencrypt-staging"
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

resource "kubernetes_ingress_v1" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.main.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "cert-manager.io/issuer"      = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts = [
        "superfactorymanager.ca",
        "www.superfactorymanager.ca",
      ]
      secret_name = "sfm-website-tls"
    }

    rule {
      host = "superfactorymanager.ca"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.frontend.metadata[0].name

              port {
                number = 80
              }
            }
          }
        }
      }
    }

    rule {
      host = "www.superfactorymanager.ca"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.frontend.metadata[0].name

              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "azurerm_dns_a_record" "apex" {
  name                = "@"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 60
  records = [
    data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].ip,
  ]
}

resource "azurerm_dns_a_record" "www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 60
  records = [
    data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].ip,
  ]
}

output "dns_name_servers" {
  value = azurerm_dns_zone.main.name_servers
}

output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "storage_container_name" {
  value = azurerm_storage_container.main.name
}
