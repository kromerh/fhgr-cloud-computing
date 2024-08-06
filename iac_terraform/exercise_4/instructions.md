**Exercise: Deploying Infrastructure with Terraform and GitHub Actions (30 minutes)**

**Step 1: Configure GitHub Repository Secrets (10 minutes)**

1. Go to your GitHub repository and open the 'Settings' tab.

2. Navigate to the 'Secrets' section.

3. Add the 'tenant ID', 'client ID', and 'client secret' from your service principal as new secrets, for example, as 'AZURE_TENANT_ID', 'AZURE_CLIENT_ID', and 'AZURE_CLIENT_SECRET'. Also add your Azure Subscription ID - 'AZURE_SUBSCRIPTION_ID' - as a secret. You find these values in the Azure portal or by running `az account show` in the Azure CLI.

**Step 2: Create GitHub Action for 'terraform plan' and 'terraform apply' (20 minutes)**

1. Create a new file under '.github/workflows' in your repository for your GitHub Action (e.g., 'tf_plan.yml').

This is what each step in the workflow file does:
    1. `name: "Terraform GitHub Actions"` - This sets the name of the workflow.
    2. `on: pull_request: types: [opened, synchronize, closed]` - This specifies the events that trigger the workflow. In this case, the workflow runs when a pull request is opened, updated, or closed.
    3. `env:` - This section is where you set environment variables. The Azure Service Principal details are stored here as secrets.
    4. `jobs:` - Workflows run jobs, which can run in parallel or sequentially. In this case, there's one job called "Terraform".
    5. `runs-on: ubuntu-latest` - This sets the type of runner that the job will run on. In this case, it's the latest version of Ubuntu.
    6. `steps:` - Jobs consist of a series of steps. Steps can run commands, run setup tasks, or run an action in your repository, a public repository, or an action published in a Docker registry.
    7. `- name: Checkout` - This step uses the GitHub 'checkout' Action to check out your repository, so your workflow can access it.
    8. `- name: Azure Login` - This step logs into Azure using the 'azure/login' Action and the provided credentials.
    9. `- name: Setup Terraform` - This step sets up Terraform using the 'hashicorp/setup-terraform' Action.
    10. `- name: Terraform Init` - This step runs the 'terraform init' command, which initializes your Terraform files in preparation for execution.
    11. `- name: Terraform Plan` - This step runs the 'terraform plan' command, which creates an execution plan for Terraform. This command is only run when a pull request is opened or updated (`if: github.event.pull_request.state == 'open'`).
    12. `- name: Terraform Apply` - This step runs the 'terraform apply' command, which applies the changes required to reach the desired state of the configuration. This command is only run when a pull request is closed (`if: github.event.pull_request.state == 'closed'`).

2. Adjust the working directory for Terraform to where the `main.tf` is located and use the secrets for Azure authentication.
