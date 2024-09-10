export RESOURCE_GROUP=rg-hkr-acr-learn
export LOCATION=switzerlandnorth
export ACR_NAME=hkracrlearn

az group create --name $RESOURCE_GROUP --location $LOCATION

az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Standard

az container create --resource-group $RESOURCE_GROUP --name mycontainer --image mcr.microsoft.com/azuredocs/aci-helloworld --ports 80 --dns-name-label $DNS_NAME_LABEL --location $LOCATION

az container show --resource-group $RESOURCE_GROUP --name mycontainer --query "{FQDN:ipAddress.fqdn,ProvisioningState:provisioningState}" --output table

az container delete --resource-group $RESOURCE_GROUP --name mycontainer
