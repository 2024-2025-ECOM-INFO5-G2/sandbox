# Déclaration des variables
variable "pub_ssh_key" {
  description = "path to SSH public key for the instances"
  type        = string
}

variable "image_version" {
  description = "The version of the Docker image to deploy"
  type        = string
}

variable "priv_ssh_key" {
  description = "path to SSH private key for the connection provisioner"
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

# Configuration du provider Azure Resource Manager
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Ressource : Groupe de ressources
resource "azurerm_resource_group" "rg" {
  name     = "MMM01_Group"
  location = "West Europe"
}

# Ressource : Réseau virtuel
resource "azurerm_virtual_network" "vnet" {
  name                = "MMM01_VNet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# Ressource : Sous-réseau
resource "azurerm_subnet" "subnet" {
  name                 = "MMM01_Subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Ressource : Groupe de sécurité réseau
resource "azurerm_network_security_group" "nsg" {
  name                = "MMM01_NSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Règle de sécurité pour autoriser le trafic SSH
  security_rule {
    name                       = "allow_ssh"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Règle de sécurité pour autoriser le trafic HTTP
  security_rule {
    name                       = "allow_http"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 80
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Règle de sécurité pour autoriser le trafic HTTPS
  security_rule {
    name                       = "allow_https"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 443
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Ressource : Adresse IP publique
resource "azurerm_public_ip" "pub_ip" {
  name                = "MMM01_PublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Ressource : Interface réseau
resource "azurerm_network_interface" "nic" {
  name                = "MMM01_NIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pub_ip.id
  }

}

# Association entre l'interface réseau et le groupe de sécurité réseau
resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Ressource : Machine virtuelle Linux
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "MMM01VM"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_DS1_v2"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.pub_ssh_key)
  }

  connection {
    type        = "ssh"
    user        = "azureuser"
    private_key = file(var.priv_ssh_key)
    host        = azurerm_public_ip.pub_ip.ip_address
  }

  os_disk {
    name                 = "MMM01_OSDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Provisionner les fichiers Dockerfile
  provisioner "file" {
    source      = "${path.module}/src/main/docker"      # Local folder path
    destination = "/home/azureuser"              # Remote folder path
  }

  # Provisionner du Fichier de Config nginx
  provisioner "file" {
    source      = "${path.module}/nginx.conf"      # Local folder path
    destination = "/home/azureuser/nginx.conf"     # Remote folder path
  }

  # Custom script to Setup the VM
  custom_data = base64encode(templatefile("${path.module}/setup-vm.sh", {
    image_version = var.image_version
  }))
}

# Sortie : Adresse IP publique
output "public_ip" {
  value = azurerm_public_ip.pub_ip.ip_address
}
