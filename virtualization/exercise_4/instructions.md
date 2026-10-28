# (Optional) Deploy the webshop Container App in green/blue deployment (35 minutes)

This exercise is optional, for those who finished exercise_3 early. It needs the resources from exercise_3: the resource group, the Container Registry, the Key Vault with the API key, the Container Apps environment and the order service. Do not clean up exercise_3 before you are done here.

We deploy a second webshop app, `webshop-revisions`, in multiple revision mode: two revisions (green and blue, with differently colored backgrounds) run side by side, and we split the traffic between them.

Open a terminal in the `exercise_4` folder. All commands below are run from there.

## Step 1: Assign the required variables (5 minutes)

1. Open `webshop_revisions.sh` and copy the values of `INITIALEN` and `LOCATION` from `exercise_3/order_service.sh`.
2. Run all `export` commands under "Step 1". Both revisions share the same `FLASK_SECRET_KEY` (it is a secret of the app, not of a revision), so the cart survives when you switch between green and blue.

## Step 2: Deploy the green revision (10 minutes)

1. Run the four lines `ACR_LOGIN_SERVER=...` to `docker login ...` together.
2. Build and push the green image: `docker buildx build ... --push webshop_green`.
3. Create the Container App with the `az containerapp create ...` command. New compared to exercise_3: `--revisions-mode multiple` allows several active revisions at the same time, and `--revision-suffix green` names the first revision `webshop-revisions--green`.
4. Assign the role "Key Vault Secrets User" to the managed identity of the app (`export MI_PRINCIPAL_ID=...` and `az role assignment create ...`).
5. Pin 100% of the traffic to the green revision (`az containerapp ingress traffic set ... --revision-weight ...--green=100`). Otherwise the next revision would automatically get all the traffic.
6. Give the revision the label `green` (`az containerapp revision label add ...`).
7. Open the URL from `az containerapp create` in the browser: you see the green webshop. The first request can take a while (cold start).

## Step 3: Deploy the blue revision and split the traffic (10 minutes)

1. Run `export WEBSHOP_IMAGE=webshop:v1_blue` and build and push the blue image: `docker buildx build ... --push webshop_blue`.
2. Create the blue revision with `az containerapp update ... --revision-suffix blue`. It gets 0% of the traffic, because green is pinned to 100%.
3. Give it the label `blue` (`az containerapp revision label add ...`).
4. Split the traffic 50/50: `az containerapp ingress traffic set ... --label-weight blue=50 green=50`.

## Step 4: Verify the green/blue deployment (5 minutes)

1. In the Azure Portal, open the Container App `webshop-revisions` and go to Application > Revisions and replicas: there are two active revisions, each with 50% of the traffic.
2. Open the URL in the browser and reload a few times: you see the green or the blue webshop, about half of the time each.
3. Each label also has its own URL: `https://webshop-revisions---blue.<rest of your URL>` (three dashes, then the label) always shows blue, `---green` always shows green. So you can test blue before giving it any traffic. In a real blue/green deployment, you would switch from green=100 to blue=100 in one step once blue is tested, and keep green as a quick way back.

## Clean up

Delete everything together with exercise_3, as described at the end of `exercise_3/instructions.md`.
