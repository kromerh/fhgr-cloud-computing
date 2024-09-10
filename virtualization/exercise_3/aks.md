https://learn.microsoft.com/en-us/training/modules/aks-deploy-container-app/3-exercise-create-aks-cluster?tabs=linux

export RESOURCE_GROUP=rg-hkr-aks-learn
export CLUSTER_NAME=aks-hkr-aks-learn
export LOCATION=switzerlandnorth

az group create --name=$RESOURCE_GROUP --location=$LOCATION


az aks create --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --node-count 2 --generate-ssh-keys --node-vm-size standard_b2ats_v2 --network-plugin azure

az aks nodepool add --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name userpool --node-count 2 --node-vm-size Standard_B1s

