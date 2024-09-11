export RESOURCE_GROUP=hkr-swissnorth-gtc
export LOCATION=switzerlandnorth
export ACR_NAME=hkracrgtcwebshop
export IMAGE=webshop:v1

<!-- az group create --name $RESOURCE_GROUP --location $LOCATION -->

az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Standard

az acr build --registry $ACR_NAME --image $IMAGE .

az acr repository list --name $ACR_NAME --output table

az acr repository show-tags --name $ACR_NAME --repository webshop --output table

az acr update -n $ACR_NAME --admin-enabled true

az acr credential show --name $ACR_NAME

The Azure Container Registry (ACR) requires authentication to ensure that only authorized entities can pull (or push) images from (or to) the registry.

In the az container create command, the --registry-username and --registry-password parameters are used to provide these authentication details.

This is because when you create a container instance, Azure needs to pull the Docker image from your container registry. To do this, it needs to authenticate with the registry to prove that it has the necessary permissions.

The username and password used are typically those of a service principal or the admin account of the ACR (if admin account is enabled). These credentials are used to authenticate the container instance service so that it can pull the image from the ACR.

The practice of keeping your container registries private and securely controlled is a good security practice to prevent unauthorized access and potential misuse of your Docker images.


Azure Container Registry (ACR) provides two passwords (password and password2) for each registry as a redundancy mechanism. If you need to regenerate one of them due to a potential compromise, you can still access the registry using the other password while updating any resources that use the compromised password. In other words, it helps avoid any downtime during the password regeneration process.

export ADMIN_USERNAME=hkracrgtcwebshop
export ADMIN_PASSWORD=cGwRtBQgQ844wQFbz1WvUgKbQdBfgoL5rGm5PMTfoZ+ACRC1hXtn
export CONTAINER_NAME=hkr-webshop-gtc

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

export MI_PRINCIPAL_ID=6ac1d572-458e-4d41-9d20-f4e5a8db07db

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
