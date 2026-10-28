# Deploy the order_service Container App (45 minutes)

Before you start:

- Docker Desktop is running: `docker info` shows a server version.
- `az login` works and `az account show` shows your subscription "Azure for Students".
- Windows users work in WSL2 (Ubuntu) with Docker Desktop's WSL integration and use the bash scripts.
- Open a terminal in the `exercise_3` folder. All commands below are run from there.

You only edit the `.sh` scripts. The Python code reads its configuration from environment variables, which the scripts set on the Container Apps.

## Step 1: Assign the required variables (5 minutes)

In this step, we set the variables for an Azure Resource Group with a Key Vault, Storage Account, Storage Queue, Container Registry, Container Apps Environment and a Container App for the order_service.

1. Open `order_service.sh` in VS Code.
2. Set `INITIALEN` to your initials and a number, e.g. `hkr100` (lowercase letters and digits only, 3 to 12 characters). All resource names are derived from it. Storage accounts, Key Vaults and registries need names that are unique in all of Azure, which is why the initials are part of the name.
3. Set `LOCATION` to a region your subscription allows, e.g. `switzerlandnorth` (Portal: Policy > Assignments > Allowed resource deployment regions).
4. Generate an API key with `python3 -c "import secrets; print(secrets.token_hex(32))"` and paste it as the value of `API_KEY`. This is the key the webshop uses to call the order_service.
5. Do not modify the other variables. If you change `API_KEY_NAME` or `SECRET_NAME`, you must also change `order_service/main.py`.
6. Run all `export` commands under "Step 1" in the terminal. In VS Code, you can select the lines, press `CMD+Shift+P` and type `Run Selected Text in Active Terminal`. It is useful to set this up as a keyboard shortcut. `SUBSCRIPTION_ID` is read from your login with `az account show`.

## Step 2: Resource providers and CLI extension (5 minutes)

1. Run the three `az provider register ...` commands. Each takes 1 to 2 minutes the first time. If you already ran them at the start of the lecture, they return immediately.
Azure providers are services that supply the resources you can deploy and manage through Azure Resource Manager. Each Azure service is a resource provider: Microsoft.App for Container Apps, Microsoft.ContainerRegistry for the registry, Microsoft.KeyVault for the Key Vault. A subscription must be registered for a provider before it can create its resources; otherwise you get the error `MissingSubscriptionRegistration`.
2. Run `az extension add --name containerapp --upgrade`. The extension adds the option `--environment-mode` that we need in Step 5.

## Step 3: Container Registry and image (10 minutes)

1. Create the resource group: `az group create --name $RESOURCE_GROUP --location $LOCATION`.
2. Create the Azure Container Registry: `az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic`. Basic is the cheapest tier and includes 10 GiB of storage, enough for our images. SKU stands for Stock Keeping Unit and is used to differentiate between different types of resources. If the name is not valid or already taken, you get an error such as `ResourceNameInvalid` or `AlreadyInUse`.
3. Enable the admin user of the registry: `az acr update -n $ACR_NAME --admin-enabled true`. We use its user name and password to push images with Docker and to let the Container Apps pull them. This is simple but a static secret; in production, a managed identity with the role AcrPull replaces the password.
4. Run the four lines `ACR_LOGIN_SERVER=...`, `ACR_USERNAME=...`, `ACR_PASSWORD=...` and `echo "$ACR_PASSWORD" | docker login ...` together (select them and Run Selected Text in Active Terminal). The first three read the login server, user name and password of the registry; `docker login` logs Docker in to the registry. The password is passed via standard input (`--password-stdin`), so it does not appear in the list of running processes. You should see `Login Succeeded`.
5. Build and push the image: `docker buildx build --platform linux/amd64 -t $ACR_LOGIN_SERVER/$IMAGE --push order_service`.
Azure Container Apps only runs Linux containers for x86-64 (`linux/amd64`). The `--platform linux/amd64` flag builds the image for this platform, also on a Mac with Apple Silicon. The `-t $ACR_LOGIN_SERVER/$IMAGE` flag tags the image with the login server of the registry and the image name. The last argument, `order_service`, is the build context: the folder with the `Dockerfile`. The `--push` flag pushes the image to the registry.
We build locally with Docker because Azure for Students does not allow builds in the registry itself (`az acr build` fails with `TasksOperationsNotAllowed`). With a pay-as-you-go subscription, ACR Tasks can build the image in Azure.
6. Navigate in the Azure Portal to the Container Registry and check under Repositories that the image `order_service` with the tag `v1` is there.

## Step 4: Key Vault, Storage Account, Queue and secrets (10 minutes)

1. Create the Key Vault: `az keyvault create --name $KEY_VAULT_NAME --resource-group $RESOURCE_GROUP --location $LOCATION`. Access to the secrets is controlled with Azure roles (RBAC).
2. Create the storage account: `az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --location $LOCATION --sku Standard_LRS`. Standard_LRS (locally redundant storage) keeps three copies of the data within one data center of the region, which is enough for this exercise.
3. We need the storage account key to create the queue, and we save it in the Key Vault: `export STORAGE_KEY=$(az storage account keys list --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" -o tsv)`.
4. Create the queue: `az storage queue create --name $QUEUE_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $STORAGE_KEY`.
5. Run `export USER_ID=...` and then the `az role assignment create --role "Key Vault Secrets Officer" ...` command. This role allows you to write secrets into the Key Vault. Even as the Owner of the subscription you cannot read or write secrets without such a role: access to the content of a Key Vault is separate from managing the Key Vault itself.
6. Set the two secrets with the two `az keyvault secret set ...` commands. If you get an error with `Forbidden` or `ForbiddenByRbac`, the new role is not active yet: wait a minute and run the commands again.

## Step 5: Container Apps environment and order_service (15 minutes)

1. Create the Container Apps environment with the `az containerapp env create ...` command. It takes about two minutes. `--environment-mode WorkloadProfiles` creates a standard environment; without it, Azure creates an "Express" environment, which supports neither the system-assigned identity we use below nor multiple revisions (exercise_4). `--logs-destination none` means that the logs are not stored; the live log stream still works. Azure for Students allows only one environment per region: if you get `MaxNumberOfRegionalEnvironmentsInSubExceeded`, you already have one.
2. Create the Container App with the `az containerapp create ...` command. It deploys the order_service into the environment:
    - `--target-port 5000`: the app listens on port 5000.
    - `--ingress external`: the app is reachable from the internet over HTTPS.
    - `--registry-server`, `--registry-username`, `--registry-password`: where and with which credentials the image is pulled.
    - `--system-assigned`: the app gets a managed identity, which we will need for the Key Vault access.
    - `--cpu 0.25 --memory 0.5Gi`: the smallest size, enough for our app.
    - `--min-replicas 1 --max-replicas 1`: exactly one replica runs, always. The order service is always on, even without orders, and therefore also costs money all the time. We will compare this with the webshop.
    - `--env-vars`: the configuration of the app: the name of the Key Vault, the storage account and the queue. `main.py` reads them with `os.environ`.
    - `--query properties.configuration.ingress.fqdn`: prints the fully qualified domain name (FQDN) of the app. Azure picks it; a custom domain would be possible but is not part of this exercise.
3. The app needs to read the secrets from the Key Vault. Run `export MI_PRINCIPAL_ID=...` to get the ID of its managed identity, and then `az role assignment create --role "Key Vault Secrets User" ...`. This role allows the app to read secrets, nothing more.
4. Until the role is active, the container cannot read the Key Vault, crashes and is restarted automatically. Run the `az containerapp revision list ...` command every 30 seconds until the revision shows `Healthy` and `Running` (1 to 2 minutes). In the Azure Portal, you see the same under Application > Revisions and replicas, and the output of the app under Monitoring > Log stream.
5. Test the order service with the last two lines of the script: `export ORDER_SERVICE_URL=...` and the `curl ...` command. The answer should be `Order processed successfully`.
6. In the Portal, navigate to the Storage Account, then Data storage > Queues > `orders`: your test order is there as a message.

# Deploy the webshop Container App (40 minutes)

The webshop uses the resources from the order_service: the registry, the Key Vault (for the API key) and the Container Apps environment.

## Step 1: Assign the required variables (5 minutes)

1. Open `webshop.sh` and copy the values of `INITIALEN` and `LOCATION` from `order_service.sh`.
2. Run all `export` commands under "Step 1". `FLASK_SECRET_KEY` is generated randomly: Flask signs the session cookie with it, and the shopping cart lives in that cookie. It is stored as a secret of the Container App, so the cart survives when the webshop scales to zero and starts again.

## Step 2: Build and push the webshop image (10 minutes)

1. Run the four lines `ACR_LOGIN_SERVER=...` to `docker login ...` together, as in the order_service.
2. Build and push the image: `docker buildx build --platform linux/amd64 -t $ACR_LOGIN_SERVER/$WEBSHOP_IMAGE --push webshop`. This time, `webshop` is the build context.

## Step 3: Deploy the webshop Container App (20 minutes)

1. Create the Container App with the `az containerapp create ...` command. The differences to the order service:
    - `--min-replicas 0 --max-replicas 1`: the webshop scales to zero when nobody uses it and starts again with the next request (scale to zero). It only costs money while it runs.
    - `--secrets flask-secret-key=...` stores the Flask secret key as a secret of the Container App; `FLASK_SECRET_KEY=secretref:flask-secret-key` passes it to the app as an environment variable.
    - `ORDER_SERVICE_FQDN=http://order-service`: apps in the same environment reach each other by their name. The webshop calls the order service inside the environment, not over the internet.
2. The webshop also reads the API key from the Key Vault. Run `export MI_PRINCIPAL_ID=...` and the `az role assignment create ...` command, as for the order service.
3. Open the URL printed by `az containerapp create` in the browser. The first request takes a while, because the webshop starts from zero (cold start). If you get an error, wait 1 to 2 minutes (the role needs time) and reload.
4. Put a few specialties into the cart and check out. In the Portal, the order is now a new message in the queue `orders`.

# Clean up (5 minutes)

Do this at the very end, after exercise_4 if you did it.

1. Delete and purge the Key Vault: `az keyvault delete --name $KEY_VAULT_NAME`, then `az keyvault purge --name $KEY_VAULT_NAME`. A deleted Key Vault is kept for 90 days ("soft delete") and its name stays reserved, e.g. for the Terraform homework. Purging deletes it for good.
2. Delete the resource group: `az group delete --name $RESOURCE_GROUP --yes --no-wait`. This deletes all resources in it. With a Container Apps environment, this takes 20 to 30 minutes; `--no-wait` lets Azure do it in the background. In the Portal, the resource group shows "Deleting" until it is gone.
3. Run `az logout`.

# (Optional) Ideas for further development

1. Exercise 4: blue/green deployment with revisions and traffic splitting (`exercise_4/instructions.md`).
2. You can try deployment scenarios with multiple replicas of the Container Apps. https://learn.microsoft.com/en-us/azure/container-apps/revisions
3. You can split traffic between different revisions of the Container Apps. https://learn.microsoft.com/en-us/azure/container-apps/traffic-splitting
