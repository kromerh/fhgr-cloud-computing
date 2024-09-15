# ----- Step 2 -------
# Copy the values below from `order_service.sh` to `webshop.sh`:
# Azure Resources
export SUBSCRIPTION_ID=b641ad8e-de23-40d6-8662-ec920f7cb0b9
export RESOURCE_GROUP=hkr-virtualisierung-webshop
export LOCATION=switzerlandnorth
export KEY_VAULT_NAME=hkr-kv-webshop
export ENVIRONMENT=webshop-env
export ACR_NAME=hkracrwebshop

# These values are different from `order_service.sh`
export WEBSHOP_IMAGE=webshop:v1
export WEBSHOP_API_NAME=webshop

# ----- Step 3 -------
# Run these four lines at the same time
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" --output tsv)
docker login $ACR_LOGIN_SERVER --username $ACR_USERNAME --password $ACR_PASSWORD

docker buildx create --use

docker buildx build --platform linux/amd64 -t $ACR_LOGIN_SERVER/$WEBSHOP_IMAGE . --push

# Azure Container App
az containerapp create \
--name $WEBSHOP_API_NAME \
--resource-group $RESOURCE_GROUP \
--environment $ENVIRONMENT \
--image $ACR_NAME.azurecr.io/$WEBSHOP_IMAGE \
--target-port 5000 \
--ingress external \
--registry-server $ACR_NAME.azurecr.io \
--system-assigned \
--min-replicas 0 \
--max-replicas 1 \
--query properties.configuration.ingress.fqdn

export MI_PRINCIPAL_ID=$(az containerapp show \
--resource-group $RESOURCE_GROUP \
--name $WEBSHOP_API_NAME \
--query identity.principalId \
--out tsv)

az role assignment create \
--role "Key Vault Secrets User" \
--assignee $MI_PRINCIPAL_ID \
--scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME

# Update the container app - in case you made changes to the image
az containerapp update \
--name $WEBSHOP_API_NAME \
--resource-group $RESOURCE_GROUP \
--image $ACR_NAME.azurecr.io/$WEBSHOP_IMAGE

