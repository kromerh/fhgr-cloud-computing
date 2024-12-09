# Create storage account
resource "azurerm_storage_account" "sa" {
  name                     = "saflaskapp2024"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create storage container
resource "azurerm_storage_container" "sc" {
  name                  = "sc-flaskapp"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

# Upload a file to the storage container
resource "azurerm_storage_blob" "sb" {
  name                   = "webshop.zip"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.sc.name
  type                   = "Block"
  source                 = "../../webshop.zip"
}

# Obtain SAS Token
data "azurerm_storage_account_sas" "sas" {
  connection_string = azurerm_storage_account.sa.primary_connection_string
  https_only        = true
  signed_version    = "2022-11-02"

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2024-08-12T00:00:00Z" # Adjust the start date as needed
  expiry = "2024-08-15T00:00:00Z" # Adjust the expiry date as needed

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = true
    add     = true
    create  = true
    update  = false
    process = true
    tag     = true
    filter  = true
  }
}

# Define the virtual machine extension
resource "azurerm_virtual_machine_extension" "example" {
  name                 = "hostname"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  # Define the settings of the extension
  settings = <<SETTINGS
{
    "fileUris": ["https://${azurerm_storage_account.sa.name}.blob.core.windows.net/${azurerm_storage_container.sc.name}/${azurerm_storage_blob.sb.name}${data.azurerm_storage_account_sas.sas.sas}"],
    "commandToExecute": "apt-get update && apt-get install -y python3 python3-pip python3-venv unzip && python3 -m venv myenv && . myenv/bin/activate && pip3 install flask && unzip webshop.zip && cd webshop && export FLASK_APP=main.py && nohup flask run --host=0.0.0.0 > flask.log 2>&1 &"
}
SETTINGS
}
