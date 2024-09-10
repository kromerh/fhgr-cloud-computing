from flask import Flask, render_template, request, redirect, url_for, session
import requests
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

app = Flask(__name__)
app.secret_key = 'a4d2a7a679c84dd792a5f5d6dd7a5792'

key_vault_name = 'stqhkr'
key_vault_uri = f"https://{key_vault_name}.vault.azure.net"

credential = DefaultAzureCredential()
client = SecretClient(vault_url=key_vault_uri, credential=credential)
api_key = client.get_secret('api-key').value

specialties = [
    {"id": 1, "name": "Bündner Nusstorte", "price": 20.00, "image": "image1.png"},
    {"id": 2, "name": "Capuns", "price": 15.00, "image": "image2.png"},
    {"id": 3, "name": "Pizokel", "price": 12.00, "image": "image3.png"},
    {"id": 4, "name": "Maluns", "price": 10.00, "image": "image4.png"},
    {"id": 5, "name": "Bündnerfleisch", "price": 30.00, "image": "image5.png"},
]

@app.route('/')
def index():
    return render_template('index.html', specialties=specialties)

@app.route('/add_to_cart/<int:spec_id>')
def add_to_cart(spec_id):
    specialty = next((x for x in specialties if x["id"] == spec_id), None)
    if specialty:
        cart = session.get('cart', [])
        cart.append(specialty)
        session['cart'] = cart
    return redirect(url_for('index'))

@app.route('/remove_from_cart/<int:item_id>', methods=['POST'])
def remove_from_cart(item_id):
    cart = session.get('cart', [])
    cart = [item for item in cart if item['id'] != item_id]
    session['cart'] = cart
    return redirect(url_for('show_cart'))

@app.route('/cart')
def show_cart():
    cart = session.get('cart', [])
    return render_template('cart.html', cart=cart)

@app.route('/checkout', methods=['POST'])
def checkout():
    cart = session.get('cart', [])
    headers = {'X-API-Key': api_key}
    response = requests.post("myorderservice.westus.azurecontainer.io", json=cart, headers=headers)
    if response.status_code == 200:
        session['cart'] = []
    return redirect(url_for('show_cart'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
