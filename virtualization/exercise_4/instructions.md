# Deploy the webshop Container App in green/blue deployment (35 minutes)

## Step 1: Prepare webshop_blue/main.py and webshop_green/main.py (5 minutes)

In this step, you will modify the `webshop_blue/main.py` file to use the Azure Resources created in the previous step.

1. Open webshop_blue/main.py in VS Code.
2. Assign values to the constant `KET_VAULT_NAME` and to any other variables (api_key) that you changed from their predefined value.

## Step 2: Assign the required environment variables (5 minutes)

In this step, we will deploy the webshop container app in a green/blue deployment. We will use the `webshop_blue` and `webshop_green` containers.

### Prepare the webshop green container

1. Navigate to the `webshop_green` directory.
2. Run the commands in `webshop_revisions.sh` (in the parent directory), be sure to assign the correct variables.

## Step 3: Deploy the green webshop container app (10 minutes)

1. Run the commands in `webshop_revisions.sh` from step 3 onwards (in the parent directory), make sure that the environment variables are set correctly.
2. When you run the docker commands, make sure that you are in the right directory, i.e., `webshop_green`.
3. Verify that the webshop container app with revisions is running in the Azure Portal, navigate to the resource group. There should be a container app `webshop-revisions`.

## Step 4: Deploy the blue webshop container app (10 minutes)

1. Run the commands in `webshop_revisions.sh` from step 4 onwards (in the parent directory), make sure that the environment variables are set correctly.
2. When you run the docker commands, make sure that you are in the right directory, i.e., `webshop_blue`.
3. Verify that the blue webshop container app is running in the Azure Portal, navigate to the resource group. There should be a container app `webshop-revisions`. In there, you should see two revisions, one for green and one for blue. Give a click on Revisions >>> Revisions and replicate to see them.

## Step 5: Verify the green/blue deployment (5 minutes)

1. Navigate to the webshop container app in the Azure Portal (webshop-revisions), open the FQDN in the browser. If you hit refresh, there should be a 50/50 chance of seeing the green or blue webshop container app, which have differently colored backgrounds.
