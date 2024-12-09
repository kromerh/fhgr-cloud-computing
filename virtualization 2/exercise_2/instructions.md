# Preparing the VM for deployment (20 minutes)

## Step 1: Creating a Virtual Machine on Azure (5 minutes)

1. Log in to the Azure portal.
2. In the left-hand menu, click on **Virtual machines**.
3. Click on **Add** to create a new virtual machine.
4. Fill in the required information (Subscription, Resource group, Virtual machine name, Region, etc.). REgion West Europe, AZ 3, Standard_B2s.
5. For the **Authentication type**, choose **SSH public key**.
6. Click on **Review + create**, then on **Create**.
7. Review that the VM was created in the Azure Portal.

## Step 2: SSH into the Virtual Machine (3 minutes)

1. Open your Terminal.
2. Navigate to the directory where your `.pem` file is located.
3. Set the correct permissions on the `.pem` file by running: `chmod 400 yourfile.pem`.
4. Use the SSH command to connect to your VM: `ssh -i yourfile.pem yourusername@yourvmip`. The standard user name if you have not changed it is `azureuser`.

## Step 3: Setting up the Environment (12 minutes)

1. Once connected to your VM, update the package lists for upgrades and new package installations: `sudo apt-get update`.
2. Install Python3 and pip: `sudo apt-get install python3 python3-pip`. Confirm with `Y`.
3. Install venv module: `sudo apt-get install python3-venv`.
4. Create a new Python virtual environment: `python3 -m venv myenv`.
5. Activate the virtual environment: `source myenv/bin/activate`.
4. Install Flask: `pip3 install flask`.

# Deploying and running the application on the VM (20 minutes)

## Step 1: Upload Your Application (10 minutes)

1. On your local machine, navigate to the directory where your web app zip file is located (webshop.zip).
2. Use the `scp` command to copy the file to your VM: `scp -i yourfile.pem webshop.zip yourusername@yourvmip:~`.
3. SSH back into your VM.
4. Unzip the file: `unzip webshop.zip`. You might need to install unzip. If so, run `sudo apt-get install unzip`.
5. Navigate into the unzipped directory: `cd webshop`.

## Step 3: Open Port 5000 on the VM (5 minutes)

1. Log in to the Azure portal.
2. In the left-hand menu, click on Virtual machines.
3. Click on the name of your virtual machine.
4. In the left-hand menu of your VM's page, click on Networking.
5. Go down to Rules, click on Create port Rule and then Add inbound port rule.
6. For Destination port ranges, enter 5000.
7. For Source port ranges, leave it as *.
8. For Protocol, choose TCP.
9. For Action, choose Allow.
10. Leave Priority as 310.
11. Click on Add.

## Step 4: Run Your Application (5 minutes)

1. Set the FLASK_APP environment variable: `export FLASK_APP=main.py`.
2. Run the application: `flask run --host=0.0.0.0`.
3. Navigate to `http://yourPUBLICvmip:5000` in your web browser.
