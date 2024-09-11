export RESOURCE_GROUP=hkr-swissnorth-gtc
export LOCATION=switzerlandnorth
export ACR_NAME=hkracrgtc
export IMAGE=order_service:v1

<!-- az group create --name $RESOURCE_GROUP --location $LOCATION -->

az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Standard

az acr build --registry $ACR_NAME --image $IMAGE .

az acr repository list --name $ACR_NAME --output table

az acr repository show-tags --name $ACR_NAME --repository order_service --output table

az acr update -n $ACR_NAME --admin-enabled true

az acr credential show --name $ACR_NAME

Azure Container Registry (ACR) provides two passwords (password and password2) for each registry as a redundancy mechanism. If you need to regenerate one of them due to a potential compromise, you can still access the registry using the other password while updating any resources that use the compromised password. In other words, it helps avoid any downtime during the password regeneration process.

export ADMIN_USERNAME=hkracrgtc
export ADMIN_PASSWORD=ZaxL4nZwBkb7cF8SBpj7P8vME8ZV1pu3OgKAiZzt5Q+ACRDsuzFm
export CONTAINER_NAME=hkr-order-service-gtc

az container create \
--resource-group $RESOURCE_GROUP \
--name $CONTAINER_NAME \
--image $ACR_NAME.azurecr.io/$IMAGE \
--registry-login-server $ACR_NAME.azurecr.io \
--ports 5000 \
--ip-address Public \
--dns-name-label $CONTAINER_NAME \
--location $LOCATION \
--registry-username $ADMIN_USERNAME \
--registry-password $ADMIN_PASSWORD \
--cpu 1 \
--memory 0.5 \
--assign-identity

az container show \
--resource-group $RESOURCE_GROUP \
--name $CONTAINER_NAME \
--query identity.principalId \
--out table

export MI_PRINCIPAL_ID=78edfe0b-f6aa-44ba-a2d9-1025d13511c0

az role assignment create \
--role "Key Vault Secrets User" \
--assignee $MI_PRINCIPAL_ID \
--scope /subscriptions/43afd889-f8ff-47b6-926b-dda4b74fee95/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/hkr-kv-gtc


az container show \
--resource-group $RESOURCE_GROUP \
--name $CONTAINER_NAME \
--output table

az container show \
--resource-group $RESOURCE_GROUP \
--name $CONTAINER_NAME \
--query ipAddress.fqdn \
--output table


az container logs \
--name $CONTAINER_NAME \
--resource-group $RESOURCE_GROUP


az container show \
--name $CONTAINER_NAME \
--resource-group $RESOURCE_GROUP \
--query 'instanceView.events[].[timestamp,message]' \
--out table


az container delete \
--name $CONTAINER_NAME \
--resource-group $RESOURCE_GROUP \
--yes

az container list \
--resource-group $RESOURCE_GROUP \
--output table


az group delete --name $RESOURCE_GROUP
