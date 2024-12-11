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
$env:WEBSHOP_IMAGE="webshop:v1"
$env:WEBSHOP_API_NAME="webshop"

# ----- Step 3 -------
# Run these four lines at the same time
$ACR_LOGIN_SERVER=$(az acr show --name $env:ACR_NAME --query loginServer --output tsv)
$ACR_USERNAME=$(az acr credential show --name $env:ACR_NAME --query username --output tsv)
$ACR_PASSWORD=$(az acr credential show --name $env:ACR_NAME --query "passwords[0].value" --output tsv)
docker login $ACR_LOGIN_SERVER --username $ACR_USERNAME --password $ACR_PASSWORD

docker buildx create --use

docker buildx build --platform linux/amd64 -t $ACR_LOGIN_SERVER/$env:WEBSHOP_IMAGE . --push

