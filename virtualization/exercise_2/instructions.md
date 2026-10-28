# Host the website in a VM (live demo, 20 minutes)

This exercise is shown live in the lecture. These are the steps to follow along or to repeat later. The same infrastructure as code is in `tf/` (Terraform homework).

You need an SSH key pair. Check with `ls ~/.ssh/id_rsa.pub`; if the file is missing, run `ssh-keygen -t rsa -b 4096` and press Enter for all questions. Windows users work in WSL2 (Ubuntu).

## Step 1: Create the Virtual Machine in the Azure Portal (5 minutes)

1. Log in to the Azure portal and open **Virtual machines** > **Create** > **Azure virtual machine**.
2. Basics:
    - Subscription: Azure for Students. Resource group: **Create new**, e.g. `rg-vm-demo`.
    - Virtual machine name: e.g. `vm-webshop`.
    - Region: **(Europe) Austria East**. Standard_B2ats_v2 is not available for Azure for Students in Switzerland North.
    - Availability options: **No infrastructure redundancy required** (in Austria East, the size is not available in zone 3).
    - Image: **Ubuntu Server 24.04 LTS - x64 Gen2**.
    - Size: **Standard_B2ats_v2** (2 vCPUs, 1 GiB memory).
    - Authentication type: **SSH public key**, user name `azureuser`, SSH public key source: **Use existing public key**, paste the content of `~/.ssh/id_rsa.pub` (`cat ~/.ssh/id_rsa.pub`).
    - Public inbound ports: **Allow selected ports**, select **SSH (22)**.
3. Click **Review + create**, then **Create**. The deployment takes 1 to 2 minutes.
4. Open the VM and note its **Public IP address**.

The portal creates a virtual network, a network interface, a public IP, a disk and a network security group (NSG) for you. The public IP has the Standard SKU, which is closed by default: only ports opened in the NSG are reachable.

## Step 2: SSH into the Virtual Machine (3 minutes)

1. Open your terminal.
2. Connect with your SSH key: `ssh azureuser@<public IP>`. Answer `yes` to the question about the host's fingerprint (only the first time).

## Step 3: Set up the environment on the VM (5 minutes)

1. Update the package lists: `sudo apt-get update`.
2. Install the venv module: `sudo apt-get install -y python3-venv`. Ubuntu 24.04 already contains Python 3.12.
3. Create a new Python virtual environment: `python3 -m venv myenv`.
4. Activate it: `source myenv/bin/activate`.
5. Install Flask: `pip3 install flask`.

## Step 4: Upload the application (3 minutes)

1. In a second terminal on your local machine, go to the `exercise_2` folder.
2. Copy the webshop folder to the VM: `scp -r webshop azureuser@<public IP>:~`.

## Step 5: Open port 5000 in the network security group (2 minutes)

1. In the portal, open the VM > **Networking** > **Network settings** > **Create port rule** > **Inbound port rule**.
2. Destination port ranges: **5000**, Protocol: **TCP**, Action: **Allow**, Name: e.g. `FlaskApp`. Leave the other values.
3. Click **Add**. The rule is active after a few seconds.

## Step 6: Run the application (2 minutes)

1. In the SSH session, go to the folder: `cd ~/webshop`.
2. Run the application on all network interfaces: `flask --app main run --host=0.0.0.0`. Without `--host=0.0.0.0`, Flask only listens on the VM itself.
3. Open `http://<public IP>:5000` in your browser.

Which of these steps were pure infrastructure work, and which were about the application?

## Clean up

Delete the resource group (portal: Resource groups > `rg-vm-demo` > Delete resource group, or `az group delete --name rg-vm-demo --yes`). This deletes the VM, its disk, the public IP and the network.

## Homework: the same with Terraform

`tf/` creates the same VM with Terraform and starts the webshop automatically (VM extension). See the comments in `tf/variables.tf`:

1. `export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)`
2. `cd tf`, then `terraform init`, `terraform plan -var initialen=<your initials>` and `terraform apply -var initialen=<your initials>`.
3. After about 3 minutes, `terraform output webshop_url` shows the URL of the webshop.
4. `terraform destroy -var initialen=<your initials>` deletes everything.
