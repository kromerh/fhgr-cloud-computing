**Exercise: Working with Azure, Terraform and Service Principal (30 minutes)**


**Step 1: Creating a Service Principal with the CLI (15 minutes)**

1. In the command prompt or terminal, run the following command to create a new Service Principal:

    ```bash
    az ad sp create-for-rbac --name ServicePrincipalName
    ```

    Replace `ServicePrincipalName` with a suitable name for your Service Principal.

2. Make a note of the `appId`, `password`, and `tenant` values in the output. These will be needed later.

**Step 2: Setting Up Environment Variables (10 minutes)**

1. Based on your operating system, set the following environment variables using the values obtained in the previous step:

    ```bash
    # Linux or MacOS
    export ARM_CLIENT_ID=<Your-App-Id>
    export ARM_CLIENT_SECRET=<Your-Client-Secret>
    export ARM_TENANT_ID=<Your-Tenant-Id>
    export ARM_SUBSCRIPTION_ID=<Your-Subscription-Id>

    # Windows
    setx ARM_CLIENT_ID "<Your-App-Id>"
    setx ARM_CLIENT_SECRET "<Your-Client-Secret>"
    setx ARM_TENANT_ID "<Your-Tenant-Id>"
    setx ARM_SUBSCRIPTION_ID "<Your-Subscription-Id>"
    ```

    Replace `<Your-App-Id>`, `<Your-Client-Secret>`, `<Your-Tenant-Id>`, and `<Your-Subscription-Id>` with your actual values.

**Step 3: Deploying Infrastructure (5 minutes)**

1. In your terminal or command prompt, navigate to the directory containing the `main.tf` file (e.g., from the previous exercise).
2. Run `terraform init` to initialize your Terraform configuration.
3. Run `terraform plan` to see the changes that will be made. Review these changes.
4. Finally, run `terraform apply` to deploy your infrastructure. Confirm the deployment when prompted.

By the end of this exercise, you should have a basic understanding of how to use an Azure Service Principal to deploy Infrastructure as Code with Terraform.
