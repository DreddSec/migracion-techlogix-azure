output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "storage_account_id" {
  value = azurerm_storage_account.main.id
}

output "primary_file_endpoint" {
  value = azurerm_storage_account.main.primary_file_endpoint
}

output "share_comun_url" {
  value = azurerm_storage_share.comun.url
}

output "share_administracion_url" {
  value = azurerm_storage_share.administracion.url
}

output "share_it_url" {
  value = azurerm_storage_share.it.url
}

output "share_produccion_url" {
  value = azurerm_storage_share.produccion.url
}
