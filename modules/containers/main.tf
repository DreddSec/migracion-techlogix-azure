# MySQL Flexible Server — reemplaza MySQL de WEB01
resource "azurerm_mysql_flexible_server" "main" {
  name                   = "mysql-${var.project}-${var.environment}"
  resource_group_name    = var.resource_group
  location               = var.mysql_location
  administrator_login    = var.mysql_admin_user
  administrator_password = var.mysql_admin_password
  sku_name               = "B_Standard_B1ms"
  version                = "8.0.21"

  storage {
    size_gb = 20
  }

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Base de datos wordpress
resource "azurerm_mysql_flexible_database" "wordpress" {
  name                = "wordpress"
  resource_group_name = var.resource_group
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

# Firewall rule — permitir acceso desde Azure services
resource "azurerm_mysql_flexible_server_firewall_rule" "azure_services" {
  name                = "allow-azure-services"
  resource_group_name = var.resource_group
  server_name         = azurerm_mysql_flexible_server.main.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# Log Analytics Workspace — Container Apps
resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.project}-${var.environment}"
  resource_group_name = var.resource_group
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Container Apps Environment
resource "azurerm_container_app_environment" "main" {
  name                       = "cae-${var.project}-${var.environment}"
  resource_group_name        = var.resource_group
  location                   = var.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Container App — WordPress
resource "azurerm_container_app" "wordpress" {
  name                         = "ca-wordpress-${var.environment}"
  resource_group_name          = var.resource_group
  container_app_environment_id = azurerm_container_app_environment.main.id
  revision_mode                = "Single"

  template {
    container {
      name   = "wordpress"
      image  = "wordpress:latest"
      cpu    = 1 
      memory = "2Gi"

      env {
        name  = "WORDPRESS_DB_HOST"
        value = "${azurerm_mysql_flexible_server.main.fqdn}:3306"
      }
      env {
        name  = "WORDPRESS_DB_USER"
        value = var.mysql_admin_user
      }
      env {
        name        = "WORDPRESS_DB_PASSWORD"
        secret_name = "mysql-password"
      }
      env {
        name  = "WORDPRESS_DB_NAME"
        value = "wordpress"
      }
    }

    min_replicas = 1
    max_replicas = 2
  }

  secret {
    name  = "mysql-password"
    value = var.mysql_admin_password
  }

  ingress {
    external_enabled = true
    target_port      = 80

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}


