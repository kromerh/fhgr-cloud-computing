# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Create a resource group where all resources will be created
resource "azurerm_resource_group" "rg" {
  name     = "rg-flaskapp"
  location = "West Europe"
}

# Create a virtual network for the VM to connect to
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-flaskapp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

# Create a subnet within the virtual network
resource "azurerm_subnet" "subnet" {
  name                 = "snet-flaskapp"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a public IP to be assigned to the VM
resource "azurerm_public_ip" "public_ip" {
  name                = "pub-ip-flaskapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create a network interface for the VM
resource "azurerm_network_interface" "nic" {
  name                = "nic-flaskapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Create a network security group to define access rules
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-flaskapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Define a rule to allow SSH access
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Define a rule to allow traffic to port 5050 for the flask app
  security_rule {
    name                       = "FlaskApp"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate the network security group with the subnet
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create the Linux virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "vm-flaskapp"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B1s"
  network_interface_ids = [azurerm_network_interface.nic.id]
  admin_username        = "azureuser"

  # Configure SSH key for the admin user. Replace the path with the path to your public key
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

