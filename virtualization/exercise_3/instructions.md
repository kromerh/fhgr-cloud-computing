# Deploy the order_service Container App (45 minutes)

## Step 1: Prepare order_service/main.py (5 minutes)

In this step, you will modify the `order_service/main.py` file to include the required constants.

1. Open order_service/main.py in VS Code.
2. Assign values to the constants `KET_VAULT_NAME`, `STORAGE_ACCOUNT_NAME` and `QUEUE_NAME`. Note them down for later use.

## Step 2: Assign the required environment variables (10 minutes)

In this step, we will deploy an Azure Resource Group with a Key Vault, Storage Account, Storage Queue, Container Registry and Container Environment and a Container App for the order_service.

1. Assign values to all of the contants under "Step 2" in `order_service.sh`.
2. In a termina, run `az login` to log in to your Azure account.
3. For the  `SUBSCRIPTION_ID` constant, pick your Subscription ID from the login or run `az account show --query id -o tsv` in the terminal.
4. Fill in the `RESOURCE_GROUP` constant with a name for your resource group, `LOCATION` with the location of your resource group and associated resources. For the `STORAGE_ACCOUNT_NAME`, `KEY_VAULT_NAME` and `QUEUE_NAME` constants, use the values you noted down in the previous step. Note that the `STORAGE_ACCOUNT_NAME` must be globally unique and can only contain lowercase letters and numbers.
5. Fill in the `ACR_NAME` constant with a name for your Azure Container Registry. Resource names may contain alpha numeric characters only and must be between 5 and 50 characters.
6. For the `IMAGE` constant, use `order_service:v1`. `v1` is the version of the image. For the `API_NAME` constant, use `order-service`. For the `ENVIRONMENT` constant, use `webshop-env`.
7. Pick a value for the `API_KEY` constant. This will be the API key for the order_service. You can use a website such as [passwordsgenerator.net](https://passwordsgenerator.net/) to generate a random string.
8. Do not modify `API_KEY_NAME` and `SECRET_NAME`. If you do, you must appropriately modify the `order_service/main.py` file and make sure the secrets are correctly set in the Key Vault.

## Step 3: Deploy the order_service Container App (30 minutes)

We will now run the script to deploy the order_service Container App. It is advised to run the commands one by one to ensure that everything is set up correctly.

1. Execute all the `export`-Commands in the terminal from "Step 2" in `order_service.sh`. In VS Code, you can do this by selecting the lines and pressing `CMD+Shift+P` and typing `Run Selected Text in Active Terminal`. It is useful to set this up as a keyboard shortcut.
2. Create the resource group by running `az group create --name $RESOURCE_GROUP --location $LOCATION`. This command will create a new resource group in the specified location. The Azure Resource Manager will automatically register neccessary providers when we execute `az commands`.
You can also enable or disable access to these providers for your subscription. Azure providers are services that supply the resources you can deploy and manage through Azure Resource Manager. Each Azure service is a resource provider. For example, Microsoft.Compute is a resource provider for virtual machines, Microsoft.Storage is a resource provider for storage accounts, etc. When you run Azure CLI commands, you are typically interacting with these providers. For example, if you run a command to create a virtual machine, you are using the Microsoft.Compute provider.
When you register a resource provider, you are giving your subscription permission to use the resources supplied by that provider. If you no longer need to use the resources, you can unregister the provider.
3. Run `az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Standard` to create a new Azure Container Registry. The SKU Standard is the default and should be sufficient for this exercise. SKU stands for Stock Keeping Unit and is used to differentiate between different types of resources. The resource name must be valid, if not, there will be an error code "ResourceNameInvalid".
4. Run `az acr update -n $ACR_NAME --admin-enabled true` to enable the admin account for the Azure Container Registry. This is necessary to push images to the registry.
5. Make sure that Docker is installed and running on your machine and that the docker daemon is running. Run `docker info` to check if Docker is running. If not, start Docker Desktop or the equivalent for your operating system.
Run all of the ACR_LOGIN_SERVER=..., ACR_USERNAME=..., ACR_PASSWORD=... and docker login ... together (select the lines and Run Selected Text in Active Terminal.)
`ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)` to get the login server name of the Azure Container Registry. This is necessary to log in to the registry with Docker when we build and push the image to the container registry. In the Azure Free Tier, we cannot use Azure Container Registry to build images. We will use Docker to build the image and push it to the registry. If you have a pay-as-you-go subscription, you can use Azure Container Registry to build images. Next, run `ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)` to get the username of the Azure Container Registry and `ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" --output tsv)` to get the password of the Azure Container Registry. These are necessary to log in to the registry with Docker.
Make sure that Docker is installed and running on your machine and that the docker daemon is running. Run `docker info` to check if Docker is running. If not, start Docker Desktop or the equivalent for your operating system.
With `docker login $ACR_LOGIN_SERVER --username $ACR_USERNAME --password $ACR_PASSWORD`, you log in to the Azure Container Registry with Docker. This is necessary to push the image to the Azure Container Registry.
8. As of August 2024, Azure Container Apps only supports Linux containers (any Linux-based x86-64 ( inux/amd64)), hence we need to create a new builder instance and use it. Run `docker buildx create --use` to create a new builder instance and use it.
9. Next, navigate to the order_service directory by running `cd order_service`. Make sure that you are in the right place by running `ls` and checking if the `Dockerfile` is present. Then run `docker buildx build --platform linux/amd64 -t $ACR_LOGIN_SERVER/$IMAGE . --push`. This command will build the Docker image for the order_service and push it to the Azure Container Registry. The `--platform linux/amd64` flag specifies that the image is built for the Linux/amd64 platform. The `-t $ACR_LOGIN_SERVER/$IMAGE` flag tags the image with the login server name of the Azure Container Registry and the image name. The `.` specifies the build context, which is the current directory. The `--push` flag pushes the image to the Azure Container Registry.
10. Navigate in the Azure Portal to the Azure Container Registry and check if the image was pushed successfully. The image should be listed under Repositories.
11. Now we create the Key Vault by running `az keyvault create --name $KEY_VAULT_NAME --resource-group $RESOURCE_GROUP --location $LOCATION`. This command will create a new Key Vault in the specified resource group and location.
12. Create the storage account by running `az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --location $LOCATION --sku Standard_LRS`. This command will create a new storage account in the specified resource group and location with the Standard_LRS replication type. This replication type is the default and should be sufficient for this exercise, it means that the data is replicated synchronously three times within one availability zone in the primary region.
13. We need the storage account key to create the storage queue and we will save it in the Key Vault. Run `export STORAGE_KEY=$(az storage account keys list --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" -o tsv)` to get the storage account key.
14. Run `az storage queue create --name $QUEUE_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $STORAGE_KEY` to create a new storage queue in the specified storage account with the specified storage account key.
15. Run `export USER_ID=$(az ad signed-in-user show --query id -o tsv)` to get the user ID of the signed-in user. Then, run `az role assignment create --role "Key Vault Secrets Officer" --assignee $USER_ID --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME` to assign the role "Key Vault Secrets Officer" to the signed-in user for the specified Key Vault. This role allows the user to set secrets in the Key Vault. Even we as Global Admins do not have the necessary permissions to set secrets in the Key Vault. This is a security feature to prevent unauthorized access to secrets. If you get an Error such as "ForbiddenByRbac", you need to wait a minute or two and try again. The permissions need some time to propagate.
16. Run `az keyvault secret set --name $SECRET_NAME --value $STORAGE_KEY --vault-name $KEY_VAULT_NAME` to set the storage account key as a secret in the Key Vault. This is necessary to access the storage account key from the order_service Container App. Run `az keyvault secret set --name $API_KEY_NAME --value $API_KEY --vault-name $KEY_VAULT_NAME` to set the API key as a secret in the Key Vault. This is necessary to access the API key from the order_service Container App and also later for the webshop.
17. Run `az containerapp env create --name $ENVIRONMENT --resource-group $RESOURCE_GROUP --location "$LOCATION" --logs-destination none` to create a new Container Environment. This environment will be used to deploy the order_service Container App. The `--logs-destination none` flag specifies that the logs of the Container App will not be stored.
18. Run `az containerapp create --name $API_NAME --resource-group $RESOURCE_GROUP --environment $ENVIRONMENT --image $ACR_NAME.azurecr.io/$IMAGE --target-port 5000 --ingress external --registry-server $ACR_NAME.azurecr.io --system-assigned --min-replicas 0 --max-replicas 1 --query properties.configuration.ingress.fqdn` to create a new Container App for the order_service. This command will deploy the order_service Container App in the specified resource group and Container Environment. The `--target-port 5000` flag specifies that the Container App listens on port 5000. The `--ingress external` flag specifies that the Container App is accessible from the internet. The `--system-assigned` flag specifies that the Container App has a system-assigned managed identity which we will need for Key Vault access. The `--registry-server $ACR_NAME.azurecr.io` flag specifies the login server name of the Azure Container Registry where the image is stored. The `--min-replicas 1` flag specifies that the Container App has a minimum of 1 replicas. The `--max-replicas 1` flag specifies that the Container App has a maximum of 1 replica. The `--query properties.configuration.ingress.fqdn` flag specifies that the fully qualified domain name (FQDN) of the Container App is returned. This FQDN is necessary to conveniently access the Container App from the internet. Azure picks the FQDN, we can purchase a custom domain and assign it to the Container App later - but we will not do this in this exercise.
19. In order for the Container App to access the Key Vault, we need to assign the role "Key Vault Secrets User" to the managed identity of the Container App. Run `export MI_PRINCIPAL_ID=$(az containerapp show --name $API_NAME --resource-group $RESOURCE_GROUP --query identity.principalId --out tsv)` to get the principal ID of the managed identity of the Container App. Then, run `az role assignment create --role "Key Vault Secrets User" --assignee $MI_PRINCIPAL_ID --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME` to assign the role "Key Vault Secrets User" to the managed identity of the Container App for the specified Key Vault. This role allows the Container App to access secrets in the Key Vault.
20. Navigate to the Azure Portal and check if the order_service Container App is running. Under `Monitoring/Log Stream` you can see the logs of the Container App.
21. You can access the Container App by navigating to the FQDN returned by the `az containerapp create` command. The Container App should be accessible from the internet and return a response when accessed. We can check this by running this Curl Command (make sure to provide the right API_KEY and FQDN):
`curl -X POST -H 'X-API-Key: API_KEY' -H 'Content-Type: application/json' -d '{"item": "test", "quantity": 200}' FQDN/order`
22. If the response is "Order processed successfully" you should see a new message in the Storage Queue. In the portal, navigate to the Storage Account and check if the message is in the Queue.

# Deploy the webshop Container App (40 minutes)

## Step 1: Prepare webshop/main.py (5 minutes)

In this step, you will modify the `webshop/main.py` file to include the required constants.

1. Open webshop/main.py in VS Code.
2. Assign values to the constants `KEY_VAULT_NAME` and `ORDER_SERVICE_FQDN` which is the fully qualified domain name of the order_service Container App.

## Step 2: Assign the required environment variables (5 minutes)

In this step, we will copy the environment variables from the `order_service.sh` script to the `webshop.sh` script. Make sure to

1. Copy `SUBSCRIPTION_ID`, `RESOURCE_GROUP`, `LOCATION`, `KEY_VAULT_NAME`, `ENVIRONMENT` and `ACR_NAME` from the `order_service.sh` script to the `webshop.sh` script.
2. You must chose values for `WEBSHOP_IMAGE` and `WEBSHOP_API_NAME` must be picked.

## Step 3: Deploy the webshop Container App (30 minutes)

We will now run the script to deploy the webshop Container App. Same as before, it is advised to run the commands one by one to ensure that everything is set up correctly.
You can only execute the content in `webshop.sh` after you have successfully executed the content in `order_service.sh`.

1. Execute all the `export`-Commands in the terminal from "Step 2" in `webshop.sh`.
2. The image for the webshop is contained in `/webshop`, hence this time we need to navigate to the webshop directory by running `cd webshop`. Make sure that you are in the right place by running `ls` and checking if the `Dockerfile` is present.
3. Execute all commands until and including `docker buildx build...`.
4. This time we can directly deploy the Container App by running the respective `az containerapp create ...` command. We have already deployed the other resources in the previous script.
5. Same as for the order-service, the webshop app needs to access the Key Vault. Run the respective `az role assignment create ...` command after we have retrieved the principal ID of the managed identity of the webshop Container App.

# Clean up (5 minutes)

1. Delete the resource group by running `az group delete --name $RESOURCE_GROUP --yes`. This command will delete the resource group and all associated resources. You can also delete the resources group in the Azure Portal.

# (Optional) Ideas for further development

1. You can try deployment scenarios with multiple replicas of the Container Apps. https://learn.microsoft.com/en-us/azure/container-apps/revisions
2. You can split traffic between different revisions of the Container Apps. https://learn.microsoft.com/en-us/azure/container-apps/traffic-splitting
