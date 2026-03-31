# Log Analytics Workspace
# Este módulo añade alertas y dashboards

# Action Group — equivalente a la configuración de alertas por email en Zabbix
resource "azurerm_monitor_action_group" "main" {
  name                = "ag-${var.project}-${var.environment}"
  resource_group_name = var.resource_group
  short_name          = "techlogix"

  email_receiver {
    name                    = "admin"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }

  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Alerta CPU alta — equivalente a el trigger Zabbix "CPU > 80%"
resource "azurerm_monitor_metric_alert" "cpu_high" {
  name                = "alert-cpu-high-${var.environment}"
  resource_group_name = var.resource_group
  scopes              = [var.container_app_id]
  description         = "CPU por encima del 80% durante 5 minutos"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.App/containerapps"
    metric_name      = "UsageNanoCores"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 800000000
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Alerta contenedor caído — equivalente a "Servidor caído" en Zabbix
resource "azurerm_monitor_metric_alert" "container_restarts" {
  name                = "alert-container-restarts-${var.environment}"
  resource_group_name = var.resource_group
  scopes              = [var.container_app_id]
  description         = "El contenedor de WordPress ha reiniciado mas de 3 veces"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.App/containerapps"
    metric_name      = "RestartCount"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 3
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Dashboard — equivalente a Grafana
resource "azurerm_portal_dashboard" "main" {
  name                = "dashboard-${var.project}-${var.environment}"
  resource_group_name = var.resource_group
  location            = var.location
  dashboard_properties = jsonencode({
    lenses = {
      "0" = {
        order = 0
        parts = {
          "0" = {
            position = { x = 0, y = 0, colSpan = 6, rowSpan = 4 }
            metadata = {
              type = "Extension/HubsExtension/PartType/MarkdownPart"
              inputs = []
              settings = {
                content = {
                  settings = {
                    content  = "## TechLogix - Infrastructure Overview\nAzure Monitor Dashboard"
                    title    = "TechLogix"
                    subtitle = "Production Environment"
                  }
                }
              }
            }
          }
        }
      }
    }
    metadata = {
      model = {}
    }
  })

  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}
