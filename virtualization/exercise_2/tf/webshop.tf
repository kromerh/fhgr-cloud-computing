# Zip the webshop folder (../webshop) at plan time. The zip lands in .terraform/ (not in Git).
data "archive_file" "webshop" {
  type        = "zip"
  source_dir  = "${path.module}/../webshop"
  output_path = "${path.module}/.terraform/webshop.zip"
  excludes    = [".DS_Store", "static/.DS_Store"]
}

# Create storage account
resource "azurerm_storage_account" "sa" {
  name                     = "stflaskapp${var.initialen}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.common_tags
}

# Create storage container
resource "azurerm_storage_container" "sc" {
  name                  = "sc-flaskapp"
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

# Upload the zipped webshop to the storage container
resource "azurerm_storage_blob" "sb" {
  name                 = "webshop.zip"
  storage_container_id = azurerm_storage_container.sc.id
  type                 = "Block"
  source               = data.archive_file.webshop.output_path
  content_md5          = data.archive_file.webshop.output_md5
}

# Obtain a read-only SAS token, valid for 24 hours from now
data "azurerm_storage_account_sas" "sas" {
  connection_string = azurerm_storage_account.sa.primary_connection_string
  https_only        = true
  signed_version    = "2022-11-02"

  resource_types {
    service   = false
    container = false
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = timestamp()
  expiry = timeadd(timestamp(), "24h")

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

# Download the webshop to the VM, install Flask and start the app as a systemd service on port 5000
resource "azurerm_virtual_machine_extension" "webshop" {
  name                 = "webshop"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"
  tags                 = var.common_tags

  # protected_settings: the SAS URL is a secret and is not shown in the portal
  protected_settings = jsonencode({
    fileUris = ["${azurerm_storage_blob.sb.url}${data.azurerm_storage_account_sas.sas.sas}"]
    commandToExecute = join(" && ", [
      "apt-get update",
      "apt-get install -y python3-venv unzip",
      "unzip -o webshop.zip -d /opt/webshop",
      "python3 -m venv /opt/webshop/venv",
      "/opt/webshop/venv/bin/pip install flask",
      "systemd-run --unit webshop --working-directory /opt/webshop /opt/webshop/venv/bin/flask --app main run --host 0.0.0.0 --port 5000",
    ])
  })

  # The SAS token changes with every plan (timestamp()); without this the script would run again on every apply
  lifecycle {
    ignore_changes = [protected_settings]
  }
}
