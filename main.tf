resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project}-${var.environment}"
  location = var.location

  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

module "networking" {
  source         = "./modules/networking"
  location       = var.location
  resource_group = azurerm_resource_group.main.name
  project        = var.project
  environment    = var.environment
}

module "identity" {
  source           = "./modules/identity"
  domain           = var.entra_domain
  default_password = var.default_password
}

module "storage" {
  source         = "./modules/storage"
  location       = var.location
  resource_group = azurerm_resource_group.main.name
  project        = var.project
  environment    = var.environment
}

module "containers" {
  source               = "./modules/containers"
  location             = var.location
  mysql_location       = var.mysql_location
  resource_group       = azurerm_resource_group.main.name
  project              = var.project
  environment          = var.environment
  mysql_admin_password = var.mysql_admin_password
}

module "monitoring" {
  source                       = "./modules/monitoring"
  location                     = var.location
  resource_group               = azurerm_resource_group.main.name
  project                      = var.project
  environment                  = var.environment
  alert_email                  = var.alert_email
  container_app_id             = module.containers.wordpress_container_app_id
}
