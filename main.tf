# 1. Blok konfiguracji Terraforma i określenie "providera"
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100.0" # Używamy stabilnej wersji wtyczki dla Azure
    }
  }
}

# 2. Inicjalizacja providera Azure
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# 3.Grupa Zasobów (Resource Group)
resource "azurerm_resource_group" "rg" {
  name     = "rg-projekt-chmurowy_asr" # Nazwa widoczna w portalu Azure
  location = "swedencentral"         
}

# 4. Sieć wirtualna (VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-projekt-chmurowy"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"] # Pula adresów IP dla całej sieci
}

# 5. Podsieć (Subnet) dla aplikacji
resource "azurerm_subnet" "subnet" {
  name                 = "snet-aplikacja"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"] # Pula adresów IP tylko dla tej podsieci
}

# 6. Monitoring (Log Analytics Workspace)
resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-projekt-chmurowy"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30 # Jak długo trzymać logi (30 dni)
}

# 7. Środowisko uruchomieniowe dla aplikacji (Container Apps Environment)
resource "azurerm_container_app_environment" "cae" {
  name                       = "cae-projekt-chmurowy"
  location                   = "germanywestcentral"
  resource_group_name        = azurerm_resource_group.rg.name
  
  # Łączymy środowisko z naszym monitoringiem, który stworzyliśmy wcześniej
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id 
}

# 8. Serwer bazy danych PostgreSQL
resource "azurerm_postgresql_flexible_server" "db" {
  name                   = "projekt-asr-179993" 
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "14"
  administrator_login    = "dbadmin"
  administrator_password = "BardzoTrudneHaslo123!" 
  zone                   = "1"
  storage_mb             = 32768
  sku_name               = "B_Standard_B1ms"
}

# Automatyczne pobranie domeny Twojego katalogu studenckiego Azure, aby adresy UPN były poprawne
data "azuread_domains" "default" {
  only_default = true
}

/*
#Dodawanie użytkowników do usługi Microsoft Entra ID
resource "azuread_user" "developer" {
  user_principal_name   = "programista179993@${data.azuread_domains.default.domains[0].domain_name}"
  display_name          = "Jan Programista (179993)"
  password              = "ZaszyfrowaneHasloDev123!"
  force_password_change = false
}

resource "azuread_user" "auditor" {
  user_principal_name   = "audytor179993@${data.azuread_domains.default.domains[0].domain_name}"
  display_name          = "Anna Audytor (179993)"
  password              = "ZaszyfrowaneHasloAudit123!"
  force_password_change = false
}

 
# Przypisywanie ról (RBAC) - Przenoszenie użytkowników do odpowiednich poziomów dostępu
# Programista otrzymuje rolę Contributor (Współtwórca) – może zarządzać infrastrukturą w grupie
resource "azurerm_role_assignment" "dev_access" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azuread_user.developer.object_id
}

# Audytor otrzymuje rolę Reader (Czytelnik) – może jedynie przeglądać zasoby i czytać logi
resource "azurerm_role_assignment" "auditor_access" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = azuread_user.auditor.object_id
}

*/


# 9. Wdrożenie aplikacji kontenerowej (Container App)
resource "azurerm_container_app" "app" {
  name                         = "app-projekt-179993"
  container_app_environment_id = azurerm_container_app_environment.cae.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "hello-world-app"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 80
    
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}