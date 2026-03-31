# VNet principal — equivalente a toda la red TechLogix
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group
  address_space       = ["10.0.0.0/16"]

  tags = {
    project = var.project
  }
}

# Subnet SERVERS (equiv. VLAN 40)
resource "azurerm_subnet" "servers" {
  name                 = "snet-servers"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.40.0/24"]
}

# Subnet DMZ (equiv. VLAN 100)
resource "azurerm_subnet" "dmz" {
  name                 = "snet-dmz"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.100.0/24"]
}

# Subnet MANAGEMENT (equiv. VLAN 10 ADMIN)
resource "azurerm_subnet" "management" {
  name                 = "snet-management"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.10.0/24"]
}

# Subnet MONITORING (equiv. VLAN 70)
resource "azurerm_subnet" "monitoring" {
  name                 = "snet-monitoring"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.70.0/24"]
}

# NSG para SERVERS — solo tráfico interno autorizado
resource "azurerm_network_security_group" "servers" {
  name                = "nsg-servers"
  location            = var.location
  resource_group_name = var.resource_group

  security_rule {
    name                       = "allow-smb-internal"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "445"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-ssh-management"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.10.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-internet-inbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

# NSG para DMZ — solo HTTP/HTTPS público
resource "azurerm_network_security_group" "dmz" {
  name                = "nsg-dmz"
  location            = var.location
  resource_group_name = var.resource_group

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-servers-inbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.40.0/24"
    destination_address_prefix = "*"
  }
}

# Asociar NSGs a subnets
resource "azurerm_subnet_network_security_group_association" "servers" {
  subnet_id                 = azurerm_subnet.servers.id
  network_security_group_id = azurerm_network_security_group.servers.id
}

resource "azurerm_subnet_network_security_group_association" "dmz" {
  subnet_id                 = azurerm_subnet.dmz.id
  network_security_group_id = azurerm_network_security_group.dmz.id
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.200.0/24"]
}

resource "azurerm_bastion_host" "main" {
  name                = "bas-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = "Developer"

  virtual_network_id = azurerm_virtual_network.main.id

  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}
