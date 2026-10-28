# ----- Step 1: Variables -------
# Copy INITIALEN and LOCATION from `order_service.sh`:
export INITIALEN=hkr100
export LOCATION=switzerlandnorth

# Do not modify the following variables (same names as in `order_service.sh`)
export SUBSCRIPTION_ID=$(az account show --query id -o tsv)
export RESOURCE_GROUP=rg-webshop-$INITIALEN
export KEY_VAULT_NAME=kv-webshop-$INITIALEN
export ACR_NAME=acrwebshop$INITIALEN
export ENVIRONMENT=webshop-env
export API_NAME=order-service

# These values are different from `order_service.sh`
export WEBSHOP_IMAGE=webshop:v1
export WEBSHOP_API_NAME=webshop
# Signs the session cookie with the cart; stored as a Container App secret
export FLASK_SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")

# ----- Step 2: Build and push the webshop image -------
# Run these four lines at the same time
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" --output tsv)
echo "$ACR_PASSWORD" | docker login $ACR_LOGIN_SERVER --username $ACR_USERNAME --password-stdin

# Run from the exercise_3 folder: webshop is the build context
docker buildx build --platform linux/amd64 -t $ACR_LOGIN_SERVER/$WEBSHOP_IMAGE --push webshop

# ----- Step 3: Deploy the webshop Container App -------
# Azure Container App
az containerapp create \
--name $WEBSHOP_API_NAME \
--resource-group $RESOURCE_GROUP \
--environment $ENVIRONMENT \
--image $ACR_NAME.azurecr.io/$WEBSHOP_IMAGE \
--target-port 5000 \
--ingress external \
--registry-server $ACR_NAME.azurecr.io \
--registry-username $ACR_USERNAME \
--registry-password $ACR_PASSWORD \
--system-assigned \
--cpu 0.25 \
--memory 0.5Gi \
--min-replicas 0 \
--max-replicas 1 \
--secrets flask-secret-key=$FLASK_SECRET_KEY \
--env-vars FLASK_SECRET_KEY=secretref:flask-secret-key KEY_VAULT_NAME=$KEY_VAULT_NAME ORDER_SERVICE_FQDN=http://$API_NAME \
--query properties.configuration.ingress.fqdn

export MI_PRINCIPAL_ID=$(az containerapp show \
--resource-group $RESOURCE_GROUP \
--name $WEBSHOP_API_NAME \
--query identity.principalId \
--out tsv)

az role assignment create \
--role "Key Vault Secrets User" \
--assignee-object-id $MI_PRINCIPAL_ID \
--assignee-principal-type ServicePrincipal \
--scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME

# The webshop scales to zero: it only starts with the first request. Open the URL from
# az containerapp create in the browser; the first request takes a while (cold start).
# If it fails, wait 1-2 minutes (the role needs time) and reload.
az containerapp revision list \
--name $WEBSHOP_API_NAME \
--resource-group $RESOURCE_GROUP \
--query "[].{name:name,health:properties.healthState,running:properties.runningState}" \
-o table

# Only if you changed the code: set a new tag (e.g. export WEBSHOP_IMAGE=webshop:v2),
# build and push again, then update the container app
az containerapp update \
--name $WEBSHOP_API_NAME \
--resource-group $RESOURCE_GROUP \
--image $ACR_NAME.azurecr.io/$WEBSHOP_IMAGE
