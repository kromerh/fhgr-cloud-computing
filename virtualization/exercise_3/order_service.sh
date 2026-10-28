# ----- Step 1: Variables -------
# Your initials + a number, e.g. hkr100: lowercase letters and digits only, 3 to 12 characters.
# They make the names below unique (storage account, key vault and registry names are global).
export INITIALEN=hkr100
# An allowed region of your subscription (Portal: Policy > Assignments > Allowed resource deployment regions)
export LOCATION=switzerlandnorth
# Generate a random key with: python3 -c "import secrets; print(secrets.token_hex(32))"
export API_KEY=...

# Do not modify the following variables
export SUBSCRIPTION_ID=$(az account show --query id -o tsv)
export RESOURCE_GROUP=rg-webshop-$INITIALEN
export STORAGE_ACCOUNT_NAME=stwebshop$INITIALEN
export QUEUE_NAME=orders
export KEY_VAULT_NAME=kv-webshop-$INITIALEN
export ACR_NAME=acrwebshop$INITIALEN
export IMAGE=order_service:v1
export API_NAME=order-service
export ENVIRONMENT=webshop-env
export API_KEY_NAME=api-key
export SECRET_NAME=storage-account-key

# ----- Step 2: Resource providers and CLI extension -------
# Resource providers: needed once per subscription, takes 1-2 minutes each.
# Best run at the start of the lecture (without --wait, they register in the background).
az provider register --namespace Microsoft.App --wait
az provider register --namespace Microsoft.ContainerRegistry --wait
az provider register --namespace Microsoft.KeyVault --wait

# Container Apps CLI extension: needed for --environment-mode below
az extension add --name containerapp --upgrade

# ----- Step 3: Container Registry and image -------
az group create --name $RESOURCE_GROUP --location $LOCATION

az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic

az acr update -n $ACR_NAME --admin-enabled true

# Run these four lines at the same time
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" --output tsv)
echo "$ACR_PASSWORD" | docker login $ACR_LOGIN_SERVER --username $ACR_USERNAME --password-stdin

# Run from the exercise_3 folder: order_service is the build context
docker buildx build --platform linux/amd64 -t $ACR_LOGIN_SERVER/$IMAGE --push order_service

# ----- Step 4: Key Vault, Storage Account, Queue and secrets -------
# Key Vault
az keyvault create --name $KEY_VAULT_NAME --resource-group $RESOURCE_GROUP --location $LOCATION

# Storage Account and Queue
az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --location $LOCATION --sku Standard_LRS
export STORAGE_KEY=$(az storage account keys list --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" -o tsv)
az storage queue create --name $QUEUE_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $STORAGE_KEY

# Put Secrets in Key Vault
export USER_ID=$(az ad signed-in-user show --query id -o tsv)
az role assignment create \
--role "Key Vault Secrets Officer" \
--assignee-object-id $USER_ID \
--assignee-principal-type User \
--scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME

# If you get "Forbidden" or "ForbiddenByRbac", wait a minute and run the two lines again
az keyvault secret set --name $SECRET_NAME --value $STORAGE_KEY --vault-name $KEY_VAULT_NAME
az keyvault secret set --name $API_KEY_NAME --value $API_KEY --vault-name $KEY_VAULT_NAME

# ----- Step 5: Container Apps environment and order_service -------
# Azure Container App environment
# --environment-mode WorkloadProfiles: without it, Azure creates an "Express" environment, which
# supports neither system-assigned identities nor multiple revisions (exercise_4)
az containerapp env create \
--name $ENVIRONMENT \
--resource-group $RESOURCE_GROUP \
--location "$LOCATION" \
--environment-mode WorkloadProfiles \
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
--registry-username $ACR_USERNAME \
--registry-password $ACR_PASSWORD \
--system-assigned \
--cpu 0.25 \
--memory 0.5Gi \
--min-replicas 1 \
--max-replicas 1 \
--env-vars KEY_VAULT_NAME=$KEY_VAULT_NAME STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT_NAME QUEUE_NAME=$QUEUE_NAME \
--query properties.configuration.ingress.fqdn

export MI_PRINCIPAL_ID=$(az containerapp show \
--resource-group $RESOURCE_GROUP \
--name $API_NAME \
--query identity.principalId \
--out tsv)

az role assignment create \
--role "Key Vault Secrets User" \
--assignee-object-id $MI_PRINCIPAL_ID \
--assignee-principal-type ServicePrincipal \
--scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME

# Until the role is assigned, the container crashes (no access to the Key Vault) and restarts by itself.
# Wait 1-2 minutes and repeat this command until Health shows "Healthy" and Running shows "Running"
az containerapp revision list \
--name $API_NAME \
--resource-group $RESOURCE_GROUP \
--query "[].{name:name,health:properties.healthState,running:properties.runningState}" \
-o table

# Test the order service: the answer should be "Order processed successfully"
export ORDER_SERVICE_URL=https://$(az containerapp show --name $API_NAME --resource-group $RESOURCE_GROUP --query properties.configuration.ingress.fqdn -o tsv)
curl -X POST -H "X-API-Key: $API_KEY" -H 'Content-Type: application/json' -d '{"item": "test", "quantity": 1}' $ORDER_SERVICE_URL/order
