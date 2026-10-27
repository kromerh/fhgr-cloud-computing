## Step 1: Set Up the Environment (5 minutes)

1. Open a Terminal.
2. Navigate to the directory where the Flask application (virtualization/webshop) is located.
3. If necessary, install the virtual environment module: `sudo apt-get install python3-venv`.
4. Create a new Python virtual environment: `python3 -m venv myenv`.
5. Activate the virtual environment: `source myenv/bin/activate`.
6. Install Flask with: `pip3 install flask`.

## Step 2: Run the Flask App: Graubünden Food Specialities (5 minutes)

1. Set the FLASK_APP environment variable: `export FLASK_APP=main.py`.
2. Run the application: `flask run`.
3. You should be able to access your application by navigating to `http://127.0.0.1:5000` in your web browser.
