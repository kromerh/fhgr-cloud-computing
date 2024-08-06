**Exercise: Introduction to GitHub Actions (60 minutes)**

**Part 1: Creating a GitHub Action to Run a Bash Command (30 minutes)**

**Step 1: Clone your Repository (5 minutes)**

1. Clone the repository from Exercise 1 to your local machine. If you have not set one up, create a new repository on GitHub.

**Step 2: Creating a GitHub Action (10 minutes)**

1. On GitHub, navigate to your repository and click on the `Actions` tab.
2. Click on `set up a workflow yourself`.
3. Replace the contents of the workflow file with the following:

    ```yaml
    name: Hello World Bash Workflow

    on: [push]

    jobs:
      build:
        runs-on: ubuntu-latest

        steps:
        - name: Checkout code
          uses: actions/checkout@v2

        - name: Run a bash command
          run: echo Hello, world!
    ```

- `name: Hello World Bash Workflow` - This is the name of your workflow. It will appear on the Actions tab of your GitHub repository.
- `on: [push]` - This tells GitHub to run the workflow whenever there's a push event to your repository. A push event occurs whenever you upload or change files in your repository.
- `jobs:` - Workflows consist of one or more jobs. Jobs run in parallel by default.
- `build:` - This is the identifier you're assigning to your job. You can choose any word you like.
- `runs-on: ubuntu-latest` - This specifies the type of runner that the job will run on. In this case, it is going to run on the latest Ubuntu virtual environment.
- `steps:` - Steps are a sequence of tasks that will be executed within a job. Each step in a job executes on the same runner, allowing the steps to share data with each other.
- `- name: Checkout code` - This is the first step in this job. The `name` field is optional and provides a description for the step in the GitHub UI.
- `uses: actions/checkout@v2` - This step uses the `checkout` action at version 2. This action checks-out your repository under `$GITHUB_WORKSPACE`, so your workflow can access it.
- `- name: Run a bash command` - This is the second step in this job. It's given the descriptive name "Run a bash command".
- `run: echo Hello, world!` - This step runs the given bash command, which in this case is `echo Hello, world!`. The `echo` command in bash will print its arguments to the standard output, which in this case is the text "Hello, world!".

4. Click on `Start commit`, then `Commit new file` to create the workflow.

**Step 3: Running the Workflow (15 minutes)**

1. Make a small change to any file in your repository, commit it, and push it to GitHub. This will trigger the Github Action.
2. Go to the `Actions` tab in your repository on GitHub.
3. You should see your workflow running.
4. Click on the workflow run to see the details.
5. You should see "Hello, world!" printed from the bash command.

**Part 2: Creating a GitHub Action to Run a Python Script (30 minutes)**

**Step 1: Creating a Python Script (10 minutes)**

1. In your local repository, create a new file called `hello.py`.
2. Open `hello.py` in your text editor and add the following code:

    ```python
    print("Hello World from Python!")
    ```

3. Save and close the file.
4. Commit the file to your repository and push it to GitHub.

**Step 2: Creating a GitHub Action (20 minutes)**

1. On GitHub, navigate to your repository and click on the `Actions` tab.
2. Click on `New workflow`.
3. Click on `set up a workflow yourself`.
4. Replace the contents of the workflow file with the following:

    ```yaml
    name: Hello World Python Workflow

    on: [push]

    jobs:
      build:
        runs-on: ubuntu-latest

        steps:
        - name: Checkout code
          uses: actions/checkout@v2

        - name: Set up Python
          uses: actions/setup-python@v2
          with:
            python-version: '3.x'

        - name: Run a Python script
          run: |
            python hello.py
    ```

5. Click on `Start commit`, then `Commit new file` to create the workflow.

**Step 3: Running the Workflow (10 minutes)**

1. Make a small change to `hello.py`, commit it, and push it to GitHub.
2. Go to the `Actions` tab in your repository on GitHub.
3. You should see your new Python workflow running.
4. Click on the workflow run to see the details.
5. You should see "Hello World from Python!" printed from the Python script.
