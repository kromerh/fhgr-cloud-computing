# ----- Step 2 -------
# Azure Resources
export SUBSCRIPTION_ID=6795c425-c0c3-438c-b25f-6757acc7f034
export RESOURCE_GROUP=hkr-virtualisierung-webshop
export LOCATION=switzerlandnorth
export STORAGE_ACCOUNT_NAME=staccwebshophkr
export QUEUE_NAME=hkrqueue
export KEY_VAULT_NAME=hkr-kv-webshop-2

# Azure Container Registry
export ACR_NAME=hkracrwebshop
export IMAGE=order_service:v1
export API_NAME=order-service

# Azure Container App
export ENVIRONMENT=webshop-env
export API_KEY=v0Fiejnh3MfmYlWz9OYN6wf5aBPrR2z3fpdpkMUsU9ZzFWinLBqXv1AixbqHdDriaEKkTURuxHD0x5mx0dBo8kcUxzMKSL2mnxnMKguY0qxugpdPy4b5p0pMg1RM24Ri

# Do not modify the following variables
export API_KEY_NAME=api-key
export SECRET_NAME=storage-account-key

# ----- Step 3 -------
az group create --name $RESOURCE_GROUP --location $LOCATION

az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Standard

az acr update -n $ACR_NAME --admin-enabled true

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
az containerapp env create \
--name $ENVIRONMENT \
--resource-group $RESOURCE_GROUP \
--location "$LOCATION" \
--logs-destination none

# Azure Container App
az containerapp create \
--name $API_NAME \
--resource-group $RESOURCE_GROUP \
--environment $ENVIRONMENT \
--image $ACR_NAME.azurecr.io/$IMAGE \
--target-port 5000 \
--ingress external \
--registry-server $ACR_NAME.azurecr.io \
--system-assigned \
--min-replicas 1 \
--max-replicas 1 \
--query properties.configuration.ingress.fqdn


export MI_PRINCIPAL_ID=$(az containerapp show \
--resource-group $RESOURCE_GROUP \
--name $API_NAME \
--query identity.principalId \
--out tsv)

az role assignment create \
--role "Key Vault Secrets User" \
--assignee $MI_PRINCIPAL_ID \
--scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME




az containerapp update \
--name $API_NAME \
--resource-group $RESOURCE_GROUP \
--image $ACR_NAME.azurecr.io/$IMAGE

curl -X POST -H 'X-API-Key: v0Fiejnh3MfmYlWz9OYN6wf5aBPrR2z3fpdpkMUsU9ZzFWinLBqXv1AixbqHdDriaEKkTURuxHD0x5mx0dBo8kcUxzMKSL2mnxnMKguY0qxugpdPy4b5p0pMg1RM24Ri' -H 'Content-Type: application/json' -d '{
"item": "books",
"quantity": 200
}' https://order-service.salmonmushroom-f41febe9.switzerlandnorth.azurecontainerapps.io/order
