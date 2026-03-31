# Storage Account — contenedor de todo
resource "azurerm_storage_account" "main" {
  name                     = "st${var.project}${var.environment}"
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  # Habilitar Azure Files con SMB
  share_properties {
    smb {
      versions                        = ["SMB3.0", "SMB3.1.1"]
      authentication_types            = ["Kerberos"]
      channel_encryption_type         = ["AES-128-CCM", "AES-128-GCM"]
      kerberos_ticket_encryption_type = ["RC4-HMAC", "AES-256"]
    }
  }

  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Shares — equivalentes a tus carpetas SMB de FILE01
resource "azurerm_storage_share" "comun" {
  name                 = "comun"
  storage_account_name = azurerm_storage_account.main.name
  quota                = 10
  enabled_protocol     = "SMB"
}

resource "azurerm_storage_share" "administracion" {
  name                 = "administracion"
  storage_account_name = azurerm_storage_account.main.name
  quota                = 10
  enabled_protocol     = "SMB"
}

resource "azurerm_storage_share" "it" {
  name                 = "cloudsolutions"
  storage_account_name = azurerm_storage_account.main.name
  quota                = 10
  enabled_protocol     = "SMB"
}

resource "azurerm_storage_share" "produccion" {
  name                 = "produccion"
  storage_account_name = azurerm_storage_account.main.name
  quota                = 10
  enabled_protocol     = "SMB"
}
