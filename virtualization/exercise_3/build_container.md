export RESOURCE_GROUP=rg-hkr-acr-learn
export LOCATION=switzerlandnorth
export ACR_NAME=hkracrlearn
export IMAGE=webshop:v1

az group create --name $RESOURCE_GROUP --location $LOCATION

az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Standard

az acr build --registry $ACR_NAME --image $IMAGE .

az acr repository list --name $ACR_NAME --output table


az acr build --registry $ACR_NAME --image app:v1 .
az acr build --registry $ACR_NAME --image app:v2 .
az acr build --registry $ACR_NAME --image app:v3 .

az acr repository show-tags --name $ACR_NAME --repository app --output table

az acr update -n $ACR_NAME --admin-enabled true

az acr credential show --name $ACR_NAME

Azure Container Registry (ACR) provides two passwords (password and password2) for each registry as a redundancy mechanism. If you need to regenerate one of them due to a potential compromise, you can still access the registry using the other password while updating any resources that use the compromised password. In other words, it helps avoid any downtime during the password regeneration process.

export ADMIN_USERNAME=hkracrlearn
export ADMIN_PASSWORD=/9Qc8Oho8KgUQDAGGppSGdN5AGPTo8XWzoU91p1DFa+ACRBUP4VM
export CONTAINER_NAME=hkr-aci-learn

az container create \
--resource-group $RESOURCE_GROUP \
--name $CONTAINER_NAME \
--image $ACR_NAME.azurecr.io/$IMAGE \
--registry-login-server $ACR_NAME.azurecr.io \
--ports 5000 \
--ip-address Public \
--location $LOCATION \
--registry-username $ADMIN_USERNAME \
--registry-password $ADMIN_PASSWORD


az container show \
--resource-group $RESOURCE_GROUP \
--name $CONTAINER_NAME \
--output table



az container delete \
--name $CONTAINER_NAME \
--resource-group $RESOURCE_GROUP \
--yes

az container list \
--resource-group $RESOURCE_GROUP \
--output table


az group delete --name $RESOURCE_GROUP
