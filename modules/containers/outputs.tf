output "wordpress_url" {
  value = "https://${azurerm_container_app.wordpress.latest_revision_fqdn}"
}

output "mysql_fqdn" {
  value = azurerm_mysql_flexible_server.main.fqdn
}

output "mysql_server_name" {
  value = azurerm_mysql_flexible_server.main.name
}

output "wordpress_container_app_id" {
  value = azurerm_container_app.wordpress.id
}
