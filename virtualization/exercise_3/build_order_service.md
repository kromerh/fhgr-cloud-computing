export RESOURCE_GROUP=hkr-virtualisierung-webshop
export LOCATION=switzerlandnorth
export ACR_NAME=hkracrwebshop
export IMAGE=order_service:v1

az group create --name $RESOURCE_GROUP --location $LOCATION

az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Standard

az acr update -n $ACR_NAME --admin-enabled true

<!-- # Get the login server name -->
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)

<!-- # Get the username and password -->
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" --output tsv)

<!-- # Use Docker to log in -->
docker login $ACR_LOGIN_SERVER --username $ACR_USERNAME --password $ACR_PASSWORD

<!-- # Create a new builder instance and use it -->
docker buildx create --use

<!-- # Build the Docker image for linux/amd64 and push it to ACR -->
docker buildx build --platform linux/amd64 -t $ACR_LOGIN_SERVER/$IMAGE . --push

export API_NAME=order-service
export ENVIRONMENT=webshop-env
export KEY_VAULT_NAME=hkr-kv-webshop

az keyvault create --name $KEY_VAULT_NAME --resource-group $RESOURCE_GROUP --location $LOCATION

<!-- Im Key Vault die Secrets eintragen -->
export STORAGE_ACCOUNT_NAME=staccwebshophkr
export SECRET_NAME=storage-account-key
export API_KEY_NAME=api-key
export API_KEY=v0Fiejnh3MfmYlWz9OYN6wf5aBPrR2z3fpdpkMUsU9ZzFWinLBqXv1AixbqHdDriaEKkTURuxHD0x5mx0dBo8kcUxzMKSL2mnxnMKguY0qxugpdPy4b5p0pMg1RM24Ri
export QUEUE_NAME=hkrqueue
export SUBSCRIPTION_ID=b641ad8e-de23-40d6-8662-ec920f7cb0b9

az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --location $LOCATION --sku Standard_LRS
STORAGE_KEY=$(az storage account keys list --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" -o tsv)
az storage queue create --name $QUEUE_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $STORAGE_KEY

export USER_ID=$(az ad signed-in-user show --query id -o tsv)
az role assignment create --role "Key Vault Secrets Officer" --assignee $USER_ID --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME

az keyvault secret set --name $SECRET_NAME --value $STORAGE_KEY --vault-name $KEY_VAULT_NAME

az keyvault secret set --name $API_KEY_NAME --value $API_KEY --vault-name $KEY_VAULT_NAME

az containerapp env create \
--name $ENVIRONMENT \
--resource-group $RESOURCE_GROUP \
--location "$LOCATION" \
--logs-destination none

az containerapp create \
--name $API_NAME \
--resource-group $RESOURCE_GROUP \
--environment $ENVIRONMENT \
--image $ACR_NAME.azurecr.io/$IMAGE \
--target-port 5000 \
--ingress external \
--registry-server $ACR_NAME.azurecr.io \
--system-assigned \
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






1. What is Container Environment?
2. Scaling?
