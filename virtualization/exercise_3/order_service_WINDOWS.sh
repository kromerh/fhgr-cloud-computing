# ----- Step 2 -------
# Azure Resources
$env:SUBSCRIPTION_ID="43afd889-f8ff-47b6-926b-dda4b74fee95"
$env:RESOURCE_GROUP="rg-virtualisierung-webshop-hkr"
$env:LOCATION="switzerlandnorth"
$env:STORAGE_ACCOUNT_NAME="staccwebshopvl06hkr"
$env:QUEUE_NAME="queuehkr"
$env:KEY_VAULT_NAME="kv-webshop-hkr"

# Azure Container Registry
$env:ACR_NAME="acrwebshophkr123"
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
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" --output tsv)
docker login $ACR_LOGIN_SERVER --username $ACR_USERNAME --password $ACR_PASSWORD

docker buildx create --use

docker buildx build --platform linux/amd64 -t $ACR_LOGIN_SERVER/$IMAGE . --push

# Key Vault
az keyvault create --name $KEY_VAULT_NAME --resource-group $RESOURCE_GROUP --location $LOCATION

# Storage Account and Queue
az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --location $LOCATION --sku Standard_LRS
export STORAGE_KEY=$(az storage account keys list --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" -o tsv)
az storage queue create --name $QUEUE_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $STORAGE_KEY

# Put Secrets in Key Vault
export USER_ID=$(az ad signed-in-user show --query id -o tsv)
az role assignment create --role "Key Vault Secrets Officer" --assignee $USER_ID --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME

az keyvault secret set --name $SECRET_NAME --value $STORAGE_KEY --vault-name $KEY_VAULT_NAME
az keyvault secret set --name $API_KEY_NAME --value $API_KEY --vault-name $KEY_VAULT_NAME

# Azure Container App environment
az containerapp env create `
--name $ENVIRONMENT `
--resource-group $RESOURCE_GROUP `
--location "$LOATION" `
--logs-destination none

# Azure Container App
az containerapp create `
--name $API_NAME `
--resource-group $RESOURCE_GROUP `
--environment $ENVIRONMENT `
--image $ACR_NAME.azurecr.io/$IMAGE `
--target-port 5000 `
--ingress external `
--registry-server $ACR_NAME.azurecr.io `
--system-assigned `
--min-replicas 1 `
--max-replicas 1 `
--query properties.configuration.ingress.fqdn


export MI_PRINCIPAL_ID=$(az containerapp show `
--resource-group $RESOURCE_GROUP `
--name $API_NAME `
--query identity.principalId `
--out tsv)

az role assignment create `
--role "Key Vault Secrets User" `
--assignee $MI_PRINCIPAL_ID `
--scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME




az containerapp update `
--name $API_NAME `
--resource-group $RESOURCE_GROUP `
--image $ACR_NAME.azurecr.io/$IMAGE

curl -X POST -H 'X-API-Key: heiko' -H 'Content-Type: application/json' -d '{
"item": "books",
"quantity": 999
}' https://order-service.salmonmushroom-f41febe9.switzerlandnorth.azurecontainerapps.io/order
