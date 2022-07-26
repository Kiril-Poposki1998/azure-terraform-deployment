resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = "West Europe"
  tags {
    environment = "tag"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "name_vnet"
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/24"]
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnet" {
  name                 = "name_subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = "10.0.0.0/24"
}

resource "azurerm_network_interface" "nic" {
  name                = "name_nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                 = "name_ip"
    subnet_id            = azurerm_subnet.subnet.id
    private_ip_address   = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}
resource "azurerm_public_ip" "pip" {
  name                         = "name_pip"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = var.resource_group_name
  public_ip_address_allocation = "Dynamic"
  domain_name_label            = "namedevops"
}

resource "azurerm_linux_virtual_machine" "linux" {
  name                  = "linux"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = "${var.resource_group_name}"
  vm_size               = "Standard_DS1_v2"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}