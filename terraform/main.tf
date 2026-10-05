terraform {
  required_version = ">= 1.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.8"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "location" {
  type    = string
  default = "chilecentral"
}

resource "azurerm_resource_group" "lab" {
  name     = "rg-plataforma-lab"
  location = var.location
}

variable "acr_name" {
  description = "Nome do ACR: unico no mundo, so letras minusculas e numeros"
  type        = string
  default     = "acrxandputolab"
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_user_assigned_identity" "app" {
  name                = "id-plataforma-lab"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}

resource "azurerm_container_app_environment" "env" {
  name                = "cae-plataforma-lab"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
}

resource "azurerm_container_app" "app" {
  name                         = "ca-plataforma-lab"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.lab.name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.app.id
  }

  ingress {
    external_enabled = true
    target_port      = 8080
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = 0
    max_replicas = 1

    container {
      name   = "web"
      image  = "${azurerm_container_registry.acr.login_server}/plataforma-lab:v1"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  depends_on = [azurerm_role_assignment.acr_pull]
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "app_url" {
  value = "https://${azurerm_container_app.app.ingress[0].fqdn}"
}
