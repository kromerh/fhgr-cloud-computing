# ----- Step 2 -------
# Copy the values below from `order_service.sh` to `webshop.sh`:
# Azure Resources
$env:SUBSCRIPTION_ID="..."
$env:RESOURCE_GROUP="rg-virtualisierung-webshop-hkr"
$env:LOCATION="switzerlandnorth"
$env:KEY_VAULT_NAME="kv-webshop-hkr100"
$env:ENVIRONMENT="webshop-env"
$env:ACR_NAME="acrwebshophkr100"

# These values are different from `order_service.sh`
$env:WEBSHOP_IMAGE="webshop:v1_green"
$env:WEBSHOP_API_NAME="webshop-revisions"

# Go to webshop_green

# ----- Step 3 -------
# Run these four lines at the same time
$ACR_LOGIN_SERVER=$(az acr show --name $env:ACR_NAME --query loginServer --output tsv)
$ACR_USERNAME=$(az acr credential show --name $env:ACR_NAME --query username --output tsv)
$ACR_PASSWORD=$(az acr credential show --name $env:ACR_NAME --query "passwords[0].value" --output tsv)
docker login $ACR_LOGIN_SERVER --username $ACR_USERNAME --password $ACR_PASSWORD

docker buildx create --use

docker buildx build --platform linux/amd64 -t $ACR_LOGIN_SERVER/$env:WEBSHOP_IMAGE . --push

# Azure Container App
az containerapp create `
--name $env:WEBSHOP_API_NAME `
--resource-group $env:RESOURCE_GROUP `
--environment $env:ENVIRONMENT `
--image $env:ACR_NAME.azurecr.io/$env:WEBSHOP_IMAGE `
--target-port 5000 `
--ingress external `
--registry-server $env:ACR_NAME.azurecr.io `
--system-assigned `
--min-replicas 0 `
--max-replicas 1 `
--revision-suffix green `
--revisions-mode multiple `
--query properties.configuration.ingress.fqdn

$env:MI_PRINCIPAL_ID=$(az containerapp show `
--resource-group $env:RESOURCE_GROUP `
--name $env:WEBSHOP_API_NAME `
--query identity.principalId `
--out tsv)

az role assignment create `
--role "Key Vault Secrets User" `
--assignee $env:MI_PRINCIPAL_ID `
--scope /subscriptions/$env:SUBSCRIPTION_ID/resourceGroups/$env:RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$env:KEY_VAULT_NAME

# Fix 50% of traffic to the revision
az containerapp ingress traffic set `
--name $env:WEBSHOP_API_NAME `
--resource-group $env:RESOURCE_GROUP `
--revision-weight $env:WEBSHOP_API_NAME--green=50

# give that revision a label 'green'
az containerapp revision label add `
--name $env:WEBSHOP_API_NAME `
--resource-group $env:RESOURCE_GROUP `
--label green `
--revision $env:WEBSHOP_API_NAME--green

# ----- Step 4 -------
# Switch to webshop_blue

# These values are different from `order_service.sh`
$env:WEBSHOP_IMAGE="webshop:v1_blue"

# Run these four lines at the same time
# When you run these lines, make sure that you are inside directory webshop_blue
$ACR_LOGIN_SERVER=$(az acr show --name $env:ACR_NAME --query loginServer --output tsv)
$ACR_USERNAME=$(az acr credential show --name $env:ACR_NAME --query username --output tsv)
$ACR_PASSWORD=$(az acr credential show --name $env:ACR_NAME --query "passwords[0].value" --output tsv)
docker login $ACR_LOGIN_SERVER --username $ACR_USERNAME --password $ACR_PASSWORD

docker buildx create --use

docker buildx build --platform linux/amd64 -t $ACR_LOGIN_SERVER/$env:WEBSHOP_IMAGE . --push

#create a second revision for blue commitId
az containerapp update `
--name $env:WEBSHOP_API_NAME `
--resource-group $env:RESOURCE_GROUP `
--image $env:ACR_NAME.azurecr.io/$env:WEBSHOP_IMAGE `
--revision-suffix blue

#give that revision a 'blue' label
az containerapp revision label add `
--name $env:WEBSHOP_API_NAME `
--resource-group $env:RESOURCE_GROUP `
--label blue `
--revision $env:WEBSHOP_API_NAME--blue

# Fix 50/50 of traffic to the revisions
az containerapp ingress traffic set `
--name $env:WEBSHOP_API_NAME `
--resource-group $env:RESOURCE_GROUP `
--label-weight blue=50 green=50
