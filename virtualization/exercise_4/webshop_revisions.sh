# Optional: needs the resources from exercise_3 (resource group, registry, Key Vault,
# Container App environment and the order service).

# ----- Step 1: Variables -------
# Copy INITIALEN and LOCATION from `exercise_3/order_service.sh`:
export INITIALEN=hkr100
export LOCATION=switzerlandnorth

# Do not modify the following variables (same names as in exercise_3)
export SUBSCRIPTION_ID=$(az account show --query id -o tsv)
export RESOURCE_GROUP=rg-webshop-$INITIALEN
export KEY_VAULT_NAME=kv-webshop-$INITIALEN
export ACR_NAME=acrwebshop$INITIALEN
export ENVIRONMENT=webshop-env
export API_NAME=order-service

# These values are different from exercise_3
export WEBSHOP_IMAGE=webshop:v1_green
export WEBSHOP_API_NAME=webshop-revisions
# Signs the session cookie with the cart; both revisions share this secret
export FLASK_SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")

# ----- Step 2: Deploy the green revision -------
# Run these four lines at the same time
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" --output tsv)
echo "$ACR_PASSWORD" | docker login $ACR_LOGIN_SERVER --username $ACR_USERNAME --password-stdin

# Run from the exercise_4 folder: webshop_green is the build context
docker buildx build --platform linux/amd64 -t $ACR_LOGIN_SERVER/$WEBSHOP_IMAGE --push webshop_green

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
--revision-suffix green \
--revisions-mode multiple \
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

# Pin 100% of the traffic to green, so that the next revision (blue) starts with 0%
az containerapp ingress traffic set \
--name $WEBSHOP_API_NAME \
--resource-group $RESOURCE_GROUP \
--revision-weight $WEBSHOP_API_NAME--green=100

# Give that revision a label 'green'
az containerapp revision label add \
--name $WEBSHOP_API_NAME \
--resource-group $RESOURCE_GROUP \
--label green \
--revision $WEBSHOP_API_NAME--green


# ----- Step 3: Deploy the blue revision and split the traffic -------
export WEBSHOP_IMAGE=webshop:v1_blue

# Run from the exercise_4 folder: webshop_blue is the build context
docker buildx build --platform linux/amd64 -t $ACR_LOGIN_SERVER/$WEBSHOP_IMAGE --push webshop_blue

# Create a second revision for blue (it gets 0% of the traffic)
az containerapp update \
--name $WEBSHOP_API_NAME \
--resource-group $RESOURCE_GROUP \
--image $ACR_NAME.azurecr.io/$WEBSHOP_IMAGE \
--revision-suffix blue

# Give that revision a label 'blue'
az containerapp revision label add \
--name $WEBSHOP_API_NAME \
--resource-group $RESOURCE_GROUP \
--label blue \
--revision $WEBSHOP_API_NAME--blue

# Split the traffic 50/50 between the two revisions
az containerapp ingress traffic set \
--name $WEBSHOP_API_NAME \
--resource-group $RESOURCE_GROUP \
--label-weight blue=50 green=50
