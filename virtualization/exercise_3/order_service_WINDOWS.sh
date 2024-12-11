# ----- Step 2 -------
# Azure Resources
$env:SUBSCRIPTION_ID="..."
$env:RESOURCE_GROUP="rg-virtualisierung-webshop-hkr"
$env:LOCATION="switzerlandnorth"
$env:STORAGE_ACCOUNT_NAME="staccwebshopvl06hkr100"
$env:QUEUE_NAME="queuehkr"
$env:KEY_VAULT_NAME="kv-webshop-hkr100"

# Azure Container Registry
$env:ACR_NAME="acrwebshophkr100"
$env:IMAGE="order_service:v1"
$env:API_NAME="order-service"

# Azure Container App
$env:ENVIRONMENT="webshop-env"
$env:API_KEY="v0Fiejnh3MfmYlWz9OYN6wf5aBPrR2z3fpdpkMUsU9ZzFWinLBqXv1AixbqHdDriaEKkTURuxHD0x5mx0dBo8kcUxzMKSL2mnxnMKguY0qxugpdPy4b5p0pMg1RM24Ri"

# Do not modify the following variables
$env:API_KEY_NAME="api-key"
$env:SECRET_NAME="storage-account-key"

# ----- Step 3 -------
az group create --name $env:RESOURCE_GROUP --location $env:LOCATION

az acr create --resource-group $env:RESOURCE_GROUP --name $env:ACR_NAME --sku Standard

az acr update -n $env:ACR_NAME --admin-enabled true

# Run these four lines at the same time
$ACR_LOGIN_SERVER=$(az acr show --name $env:ACR_NAME --query loginServer --output tsv)
$ACR_USERNAME=$(az acr credential show --name $env:ACR_NAME --query username --output tsv)
$ACR_PASSWORD=$(az acr credential show --name $env:ACR_NAME --query "passwords[0].value" --output tsv)
docker login $ACR_LOGIN_SERVER --username $ACR_USERNAME --password $ACR_PASSWORD

docker buildx create --use

docker buildx build --platform linux/amd64 -t $ACR_LOGIN_SERVER/$env:IMAGE . --push

# Key Vault
az keyvault create --name $env:KEY_VAULT_NAME --resource-group $env:RESOURCE_GROUP --location $env:LOCATION

# Storage Account and Queue
az storage account create --name $env:STORAGE_ACCOUNT_NAME --resource-group $env:RESOURCE_GROUP --location $env:LOCATION --sku Standard_LRS
$env:STORAGE_KEY=$(az storage account keys list --account-name $env:STORAGE_ACCOUNT_NAME --query "[0].value" -o tsv)
az storage queue create --name $env:QUEUE_NAME --account-name $env:STORAGE_ACCOUNT_NAME --account-key $env:STORAGE_KEY

# Put Secrets in Key Vault
$env:USER_ID=$(az ad signed-in-user show --query id -o tsv)
az role assignment create --role "Key Vault Secrets Officer" --assignee $env:USER_ID --scope /subscriptions/$env:SUBSCRIPTION_ID/resourceGroups/$env:RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$env:KEY_VAULT_NAME

az keyvault secret set --name $env:SECRET_NAME --value $env:STORAGE_KEY --vault-name $env:KEY_VAULT_NAME
az keyvault secret set --name $env:API_KEY_NAME --value $env:API_KEY --vault-name $env:KEY_VAULT_NAME

# Azure Container App environment
az containerapp env create `
--name $env:ENVIRONMENT `
--resource-group $env:RESOURCE_GROUP `
--location "$env:LOATION" `
--logs-destination none

# Azure Container App
az containerapp create `
--name $env:API_NAME `
--resource-group $env:RESOURCE_GROUP `
--environment $env:ENVIRONMENT `
--image $env:ACR_NAME.azurecr.io/$env:IMAGE `
--target-port 5000 `
--ingress external `
--registry-server $env:ACR_NAME.azurecr.io `
--system-assigned `
--min-replicas 1 `
--max-replicas 1 `
--query properties.configuration.ingress.fqdn

$env:MI_PRINCIPAL_ID=$(az containerapp show `
--resource-group $env:RESOURCE_GROUP `
--name $env:API_NAME `
--query identity.principalId `
--out tsv)

az role assignment create `
--role "Key Vault Secrets User" `
--assignee $env:MI_PRINCIPAL_ID `
--scope /subscriptions/$env:SUBSCRIPTION_ID/resourceGroups/$env:RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$env:KEY_VAULT_NAME

az containerapp update `
--name $env:API_NAME `
--resource-group $env:RESOURCE_GROUP `
--image $env:ACR_NAME.azurecr.io/$env:IMAGE

