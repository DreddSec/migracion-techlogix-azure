output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "subnet_servers_id" {
  value = azurerm_subnet.servers.id
}

output "subnet_dmz_id" {
  value = azurerm_subnet.dmz.id
}

output "subnet_management_id" {
  value = azurerm_subnet.management.id
}

output "subnet_monitoring_id" {
  value = azurerm_subnet.monitoring.id
}
