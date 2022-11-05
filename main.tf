
### STAGING ENVIRONMENT 
resource "azurerm_resource_group" "staging-rg" {
  name     = "dev-rg"
  location = var.region


  tags = {
    "environment" = var.tag
  }
}

resource "azurerm_network_security_group" "staging-sg" {
  name                = "dev-sg"
  location            = azurerm_resource_group.staging-rg.location
  resource_group_name = azurerm_resource_group.staging-rg.name

  tags = {
    "environment" = var.tag
  }
}

resource "azurerm_network_security_rule" "staging-nsr" {
  name                        = "SSH connection"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.staging-rg.name
  network_security_group_name = azurerm_network_security_group.staging-sg.name
}

resource "azurerm_subnet_network_security_group_association" "staging-sga" {
  subnet_id                 = azurerm_subnet.staging-subnet.id
  network_security_group_id = azurerm_network_security_group.staging-sg.id
}

resource "azurerm_virtual_network" "staging-vn" {
  name                = "dev-vn"
  location            = var.region
  resource_group_name = azurerm_resource_group.staging-rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    "environment" = var.tag
  }
}

resource "azurerm_subnet" "staging-subnet" {
  name                 = "dev-subnet"
  resource_group_name  = azurerm_resource_group.staging-rg.name
  virtual_network_name = azurerm_virtual_network.staging-vn.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "staging-ip" {
  name                = "dev-ip.0"
  resource_group_name = azurerm_resource_group.staging-rg.name
  location            = azurerm_resource_group.staging-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "staging-vm-nic" {
  name                = "dev-nic"
  location            = azurerm_resource_group.staging-rg.location
  resource_group_name = azurerm_resource_group.staging-rg.name

  ip_configuration {
    name                          = "dev-nic-ip"
    subnet_id                     = azurerm_subnet.staging-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.staging-ip.id
  }

  tags = {
    "environment" = var.tag
  }
}

resource "azurerm_linux_virtual_machine" "staging-vm" {
  name                            = "dev-linux-vm"
  resource_group_name             = azurerm_resource_group.staging-rg.name
  location                        = azurerm_resource_group.staging-rg.location
  size                            = "Standard_F2"
  admin_username                  = "adminL"
  admin_password                  = "Secret!1"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.staging-vm-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}


### PRODUCTION ENVIRONMENT
resource "azurerm_resource_group" "prod-rg" {
  name     = "prod-rg"
  location = var.region


  tags = {
    "environment" = "prod"
  }
}

resource "azurerm_network_security_group" "prod-sg" {
  name                = "prod-sg"
  location            = azurerm_resource_group.prod-rg.location
  resource_group_name = azurerm_resource_group.prod-rg.name

  tags = {
    "environment" = "prod"
  }
}

resource "azurerm_network_security_rule" "prod-nsr" {
  name                        = "RDP connection"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.prod-rg.name
  network_security_group_name = azurerm_network_security_group.prod-sg.name
}

resource "azurerm_subnet_network_security_group_association" "prod-sga" {
  subnet_id                 = azurerm_subnet.prod-subnet.id
  network_security_group_id = azurerm_network_security_group.prod-sg.id
}

resource "azurerm_virtual_network" "prod-vn" {
  name                = "prod-vn"
  location            = var.region
  resource_group_name = azurerm_resource_group.staging-rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    "environment" = "prod"
  }
}

resource "azurerm_subnet" "prod-subnet" {
  name                 = "prod-subnet"
  resource_group_name  = azurerm_resource_group.staging-rg.name
  virtual_network_name = azurerm_virtual_network.staging-vn.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "prod-ip" {
  name                = "prod-ip.0"
  resource_group_name = azurerm_resource_group.prod-rg.name
  location            = azurerm_resource_group.prod-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "prod"
  }
}

resource "azurerm_network_interface" "prod-vm-nic" {
  name                = "prod-nic"
  location            = azurerm_resource_group.prod-rg.location
  resource_group_name = azurerm_resource_group.prod-rg.name

  ip_configuration {
    name                          = "prod-nic-ip"
    subnet_id                     = azurerm_subnet.prod-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.prod-ip.id
  }

  tags = {
    "environment" = "prod"
  }
}

resource "azurerm_windows_virtual_machine" "prod-vm" {
  name                = "prod-windows-vm"
  resource_group_name = azurerm_resource_group.prod-rg.name
  location            = azurerm_resource_group.prod-rg.location
  size                = "Standard_F2"
  admin_username      = "adminW"
  admin_password      = "Secret!1"
  network_interface_ids = [
    azurerm_network_interface.prod-vm-nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  tags = {
    "environment" = "prod"
  }
}
