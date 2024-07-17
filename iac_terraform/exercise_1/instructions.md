**Exercise: Working with GitHub, VS Code and Terraform (45 minutes)**
   
**Step 1: Setting up the Environment (5 minutes)**  
   
1. Open Visual Studio Code (VS Code).  
2. Install extension 'Source Control' if not already installed.
3. Install extension 'Git graph - https://marketplace.visualstudio.com/items?itemName=mhutchie.git-graph'.
4. Restart VS Code if required after the extension installation.  
   
**Step 2A: Cloning the Repository (5 minutes) - VS Code**  
   
1. Click on the 'Source Control' icon in the Activity Bar on the side of VS Code.   
2. Click on 'Clone Repository'. If asked for your GitHub username and password, enter them.
3. In the input box, enter the URL of the repository you want them to clone, then press `Enter`.  
4. Choose a location on your local machine where you want to clone the repository, then click 'Select Repository Location'.  
5. A new notification will appear asking if you would like to open the cloned repository. Click 'Open' to open the newly cloned repository.  

**Step 2B: Cloning the Repository (5 minutes) - Command Line / Terminal**  

1. Open a terminal window.
2. Run the following command to clone the repository:  
   `git clone repository_url`
   where `repository_url` is the URL of the repository you want to clone. If asked for your GitHub username and password, enter them.
3. Change into the cloned repository directory:
    `cd repository_name`
    where `repository_name` is the name of the repository you just cloned.

**Step 3: Add Terraform Code to the main branch (10 minutes)**

1. In the Explorer on the side, copy files `main.tf`, `variables.tf` and `outputs.tf` from the last exercise into the repository.
2. Save the files.
3. Run `terraform init` to initialize the Terraform configuration, `terraform plan` to see the execution plan, and `terraform apply` to apply the changes.
4. Make sure the .gitignore file is present in the repository and it is ignoring the .terraform directory. Double check!
5. Commit and push the changes to the main branch:
   `git add .`
   `git commit -m "Added Terraform code"`
   `git push origin main`

   Note:
   - git add . will add all the files in the directory to the staging area.
   - git commit -m "Added Terraform code" will commit the changes with the message "Added Terraform code".
   - git push origin main will push the changes to the main branch on GitHub.
6. Verify the changes on GitHub. Log in to your GitHub account and navigate to the repository. You should see the new files and folders you added.
7. (Optional) If you have Git Graph extension installed, you can view the commit history by clicking on the Source Control icon and then clicking on the Git Graph icon. The icon is to the right of the refresh icon in the upper left corner of the Source Control view.
8. (Optional) Verify in Azure that the resources have been created successfully if they did not exist.

**Step 4: Create a new Branch in Github (5 minutes)**

1. Go to the repository on GitHub.
2. Click on the 'main' branch dropdown and type in the name of the new branch you want to create, e.g., `feature/update_tf`.
3. Click on the 'Create branch: feature/update_tf' button.
4. Clone the new branch to your local machine (navigate back to VS Code):
   `git fetch`
   `git checkout -b feature/update_tf`

    Notes:
    - git fetch will fetch the latest changes from the remote repository.
    - git checkout -b feature/update_tf will create a new branch called feature/update_tf and switch to it.
5. Verify in the lower left corner of VS Code that you are now on the new branch. It should say `feature/update_tf`.

**Step 5: Modify some Terraform Code and push changes to the new branch (5 minutes)**

1. Make some changes to the Terraform code in the `main.tf` file.
2. Save the file.
3. Add, commit, and push the changes to the new branch:
   `git add .`
   `git commit -m "Updated Terraform code"`
   `git push origin feature/update_tf`

   Note:
   - git add . will add all the files in the directory to the staging area.
   - git commit -m "Updated Terraform code" will commit the changes with the message "Updated Terraform code".
   - git push origin feature/update_tf will push the changes to the feature/update_tf branch on GitHub.
4. Verify the changes on GitHub. Log in to your GitHub account and navigate to the repository. You should see the new commit on the feature/update_tf branch.

**Step 6: Create a Pull Request (5 minutes)**

1. Go to the repository on GitHub.
2. Click on the 'Pull requests' tab.
3. Click on the 'New pull request' button.
4. Select the base branch (the branch you want to merge the changes into) as `main` and the compare branch (the branch with the changes) as `feature/update_tf`.
5. Click on the 'Create pull request' button.
6. Add a title and description for the pull request.
7. Observe the changes in the pull request by clicking on the 'Files changed' tab.
8. If you are satisfied with the changes, click on merge pull request and confirm the merge.
9. It is best practice to delete the feature branch after merging the changes. You can do this by clicking on the 'Delete branch' button in the pull request.

**Step 7: Deploy the Terraform Code (5 minutes)**

1. Go back to your local machine and switch to the main branch:
   `git checkout main`
2. Pull the latest changes from the remote repository:
   `git pull origin main`
3. Run `terraform init` to initialize the Terraform configuration, `terraform plan` to see the execution plan, and `terraform apply` to apply the changes.
4. Verify in Azure that the resources have been updated successfully.
   
**Step 8: Exploring Commits (Optional)**  

1. Click on the 'Source Control' icon.  
2. Click on the '...' icon at the top of the Source Control view.  
3. Click on 'View History' to see the commit history.  