# ☁️ TechLogix — Migración a Azure Cloud

> Migración y modernización de la infraestructura on-premise de **TechLogix** a Microsoft Azure, utilizando Terraform como herramienta de IaC.

> Este proyecto es la evolución cloud del [proyecto ASIR on-premise](https://github.com/DreddSec/proyecto-asir-techlogix), donde se implementó una infraestructura completa con pfSense, Samba AD, servidores de archivos, web y monitorización sobre VirtualBox.

---

## Arquitectura

### 🏬 On-Premise → 🅰️ Azure

| Componente On-Premise | Servicio Azure | Tipo de migración |
|---|---|---|
| pfSense (firewall/router) | VNet + NSGs | Migración directa |
| Samba AD (DC01 + DC02) | Entra ID | Migración directa |
| FILE01 (SMB/FTP) | Azure Files (SMB) | Migración directa |
| WEB01 (LAMP + WordPress) | Container Apps + MySQL Flexible | Modernización |
| MON01 (Zabbix + Grafana) | Azure Monitor + Log Analytics | Modernización |
| BAK01 (Bacula) | MySQL built-in backup (7 días) | Modernización |
| SEC01 (OpenVPN) | Azure Bastion (Developer SKU) | Modernización |

### Diagrama de recursos desplegados

```
Azure Subscription
└── rg-techlogix-prod
    │
    ├── Networking
    │   ├── vnet-techlogix-prod (10.0.0.0/16)
    │   │   ├── snet-servers      (10.0.40.0/24)  + nsg-servers
    │   │   ├── snet-dmz          (10.0.100.0/24) + nsg-dmz
    │   │   ├── snet-management   (10.0.10.0/24)
    │   │   └── snet-monitoring   (10.0.70.0/24)
    │   │   └── bas-techlogix-prod (Azure Bastion Developer — acceso admin seguro)
    │
    ├── Identity (Entra ID)
    │   ├── GRP_Administracion → carlos.ruiz, maria.lopez
    │   ├── GRP_IT             → david.garcia, laura.fernandez
    │   └── GRP_Produccion     → pedro.sanchez, jorge.navarro
    │
    ├── Storage
    │   └── sttechlogixprod (Azure Files)
    │       ├── share: comun
    │       ├── share: administracion
    │       ├── share: it
    │       └── share: produccion
    │
    ├── Containers
    │   ├── mysql-techlogix-prod (MySQL Flexible Server 8.0, B1ms)
    │   │   └── database: wordpress
    │   ├── cae-techlogix-prod (Container Apps Environment)
    │   │   └── ca-wordpress-prod (WordPress:latest)
    │   └── log-techlogix-prod (Log Analytics Workspace)
    │
    └── Monitoring
        ├── ag-techlogix-prod (Action Group — alertas por email)
        ├── alert-cpu-high-prod (CPU > 80% durante 15min → severidad 2)
        ├── alert-container-restarts-prod (reinicios > 3 → severidad 1)
        └── dashboard-techlogix-prod (Portal Dashboard)
```

---

## 📋 Estructura del repositorio

```
techlogix-azure/
├── main.tf               # Punto de entrada, llama a todos los módulos
├── providers.tf          # Providers azurerm + azuread + backend remoto
├── variables.tf          # Declaración de variables
├── outputs.tf            # Outputs del proyecto
├── terraform.tfvars      # Valores del entorno (no subir a git)
└── modules/
    ├── networking/       # VNet, subnets, NSGs
    ├── identity/         # Grupos y usuarios Entra ID
    ├── storage/          # Storage Account + Azure Files shares
    ├── containers/       # MySQL, Container Apps, WordPress
    └── monitoring/       # Azure Monitor, alertas, dashboard
```

---

## ❓ Decisiones de diseño

> **¿Por qué Container Apps en vez de una VM con LAMP?**
El stack LAMP original (Apache + MySQL + PHP + WordPress en una VM) es un enfoque monolítico. Container Apps permite escalar el frontend independientemente de la base de datos, aplicar actualizaciones sin downtime mediante revisiones, y eliminar la gestión del sistema operativo subyacente. MySQL Flexible Server gestiona parches, backups y alta disponibilidad de forma nativa.

> **¿Por qué Azure Files en vez de una VM con Samba?**
Azure Files proporciona el mismo protocolo SMB 3.x que el FILE01 on-premise pero sin gestión de servidor. Los shares heredan la misma estructura de permisos por departamento (`comun`, `administracion`, `it`, `produccion`).

> **¿Por qué Azure Monitor en vez de Zabbix?**
Zabbix requiere una VM dedicada, agentes en cada servidor y mantenimiento continuo. Azure Monitor es nativo al cloud, no requiere infraestructura adicional y se integra directamente con Container Apps y el resto de servicios Azure.

> **Terraform como IaC en vez de Bicep:**
Terraform es agnóstico al cloud provider (Azure, AWS, GCP) lo que lo hace más transferible. El state remoto en Azure Storage garantiza que la infraestructura puede ser gestionada en equipo sin conflictos.

---

## 🛡 State remoto

> El estado de Terraform se almacena de forma remota en Azure Storage, siguiendo las buenas prácticas de trabajo en equipo:

```hcl
backend "azurerm" {
  resource_group_name  = "rg-techlogix-prod"
  storage_account_name = "sttechlogixprod"
  container_name       = "tfstate"
  key                  = "techlogix.prod.tfstate"
}
```

---

## ⚔️ Seguridad implementada

| Control | Implementación |
|---|---|
| Segmentación de red | 4 subnets con NSGs dedicados |
| Least privilege NSG | SERVERS solo acepta SMB/SSH desde subnets internas |
| DMZ aislada | NSG-DMZ bloquea tráfico desde subnet SERVERS |
| Secrets en Terraform | Variables marcadas como `sensitive = true` |
| TLS 1.2 mínimo | `min_tls_version = "TLS1_2"` en Storage Account |
| Contraseña MySQL como secret | Inyectada via secret en Container App, no en variable de entorno plana |
| Backup MySQL | Retención de 7 días nativa del servidor |

---

## 📊 Recursos desplegados (41 total)

```
terraform state list
```

```
azurerm_resource_group.main
module.containers.azurerm_container_app.wordpress
module.containers.azurerm_container_app_environment.main
module.containers.azurerm_log_analytics_workspace.main
module.containers.azurerm_mysql_flexible_database.wordpress
module.containers.azurerm_mysql_flexible_server.main
module.containers.azurerm_mysql_flexible_server_firewall_rule.azure_services
module.identity.azuread_group.administracion
module.identity.azuread_group.it
module.identity.azuread_group.produccion
module.identity.azuread_group_member.carlos_admin
module.identity.azuread_group_member.david_it
module.identity.azuread_group_member.jorge_prod
module.identity.azuread_group_member.laura_it
module.identity.azuread_group_member.maria_admin
module.identity.azuread_group_member.pedro_prod
module.identity.azuread_user.carlos_ruiz
module.identity.azuread_user.david_garcia
module.identity.azuread_user.jorge_navarro
module.identity.azuread_user.laura_fernandez
module.identity.azuread_user.maria_lopez
module.identity.azuread_user.pedro_sanchez
module.monitoring.azurerm_monitor_action_group.main
module.monitoring.azurerm_monitor_metric_alert.container_restarts
module.monitoring.azurerm_monitor_metric_alert.cpu_high
module.monitoring.azurerm_portal_dashboard.main
module.networking.azurerm_bastion_host.main
module.networking.azurerm_network_security_group.dmz
module.networking.azurerm_network_security_group.servers
module.networking.azurerm_subnet.bastion
module.networking.azurerm_subnet.dmz
module.networking.azurerm_subnet.management
module.networking.azurerm_subnet.monitoring
module.networking.azurerm_subnet.servers
module.networking.azurerm_subnet_network_security_group_association.dmz
module.networking.azurerm_subnet_network_security_group_association.servers
module.networking.azurerm_virtual_network.main
module.storage.azurerm_storage_account.main
module.storage.azurerm_storage_share.administracion
module.storage.azurerm_storage_share.comun
module.storage.azurerm_storage_share.it
module.storage.azurerm_storage_share.produccion
```

---

## 💰 Costes estimados

| Recurso | SKU | $/mes aprox |
|---|---|---|
| Container Apps (WordPress) | Consumption | ~€5 |
| MySQL Flexible Server | B_Standard_B1ms | ~€12 |
| Azure Files | Standard LRS 40GB | ~€2 |
| Log Analytics Workspace | Pay-per-GB (5GB free) | ~€0 |
| VNet + NSGs + Public IP | — | ~€3 |
| Azure Monitor alertas | — | ~€0 |
| Azure Bastion | Desarollador | ~€0
| **Total** | | **~€22-25/mes** |

---

## ⚙️ Tecnologías utilizadas

- **Terraform** >= 1.3 — IaC
- **Azure Provider** ~> 4.0 — recursos ARM
- **AzureAD Provider** ~> 3.0 — Entra ID
- **Azure Container Apps** — orquestación de contenedores serverless
- **Azure Database for MySQL Flexible Server** 8.0 — base de datos gestionada
- **Azure Files** — almacenamiento de archivos SMB
- **Azure Monitor** — observabilidad y alertas
- **Entra ID** — identidad y acceso
- **Azure Bastion** - acceso remoto seguro

---

## 📤 Proyecto base

> Este proyecto es la migración cloud del proyecto ASIR on-premise TechLogix, disponible en:

👉 [github.com/DreddSec/proyecto-asir-techlogix](https://github.com/DreddSec/proyecto-asir-techlogix)
