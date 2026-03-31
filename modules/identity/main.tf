# Grupos — equivalentes a tus GRP_* de Samba
resource "azuread_group" "administracion" {
  display_name     = "GRP_Administracion"
  security_enabled = true
  description      = "Departamento de Administración - TechLogix"
}

resource "azuread_group" "it" {
  display_name     = "GRP_IT"
  security_enabled = true
  description      = "Departamento IT - TechLogix"
}

resource "azuread_group" "produccion" {
  display_name     = "GRP_Produccion"
  security_enabled = true
  description      = "Departamento de Producción - TechLogix"
}

# Usuarios — mismos que en tu Samba AD
resource "azuread_user" "carlos_ruiz" {
  user_principal_name = "carlos.ruiz@${var.domain}"
  display_name        = "Carlos Ruiz"
  given_name          = "Carlos"
  surname             = "Ruiz"
  department          = "Administracion"
  job_title           = "Administrador"
  password            = var.default_password
}

resource "azuread_user" "maria_lopez" {
  user_principal_name = "maria.lopez@${var.domain}"
  display_name        = "María López"
  given_name          = "María"
  surname             = "López"
  department          = "Administracion"
  job_title           = "Administradora"
  password            = var.default_password
}

resource "azuread_user" "david_garcia" {
  user_principal_name = "david.garcia@${var.domain}"
  display_name        = "David García"
  given_name          = "David"
  surname             = "García"
  department          = "IT"
  job_title           = "Técnico IT"
  password            = var.default_password
}

resource "azuread_user" "laura_fernandez" {
  user_principal_name = "laura.fernandez@${var.domain}"
  display_name        = "Laura Fernández"
  given_name          = "Laura"
  surname             = "Fernández"
  department          = "IT"
  job_title           = "Técnica IT"
  password            = var.default_password
}

resource "azuread_user" "pedro_sanchez" {
  user_principal_name = "pedro.sanchez@${var.domain}"
  display_name        = "Pedro Sánchez"
  given_name          = "Pedro"
  surname             = "Sánchez"
  department          = "Produccion"
  job_title           = "Operario"
  password            = var.default_password
}

resource "azuread_user" "jorge_navarro" {
  user_principal_name = "jorge.navarro@${var.domain}"
  display_name        = "Jorge Navarro"
  given_name          = "Jorge"
  surname             = "Navarro"
  department          = "Produccion"
  job_title           = "Operario"
  password            = var.default_password
}

# Asignación de usuarios a grupos
resource "azuread_group_member" "carlos_admin" {
  group_object_id  = azuread_group.administracion.object_id
  member_object_id = azuread_user.carlos_ruiz.object_id
}

resource "azuread_group_member" "maria_admin" {
  group_object_id  = azuread_group.administracion.object_id
  member_object_id = azuread_user.maria_lopez.object_id
}

resource "azuread_group_member" "david_it" {
  group_object_id  = azuread_group.it.object_id
  member_object_id = azuread_user.david_garcia.object_id
}

resource "azuread_group_member" "laura_it" {
  group_object_id  = azuread_group.it.object_id
  member_object_id = azuread_user.laura_fernandez.object_id
}

resource "azuread_group_member" "pedro_prod" {
  group_object_id  = azuread_group.produccion.object_id
  member_object_id = azuread_user.pedro_sanchez.object_id
}

resource "azuread_group_member" "jorge_prod" {
  group_object_id  = azuread_group.produccion.object_id
  member_object_id = azuread_user.jorge_navarro.object_id
}
