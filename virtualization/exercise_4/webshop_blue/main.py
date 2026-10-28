from flask import Flask, render_template, request, redirect, url_for, session
import requests
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import logging
import os
import secrets

# Configuration comes from the environment (az containerapp create --env-vars ...)
KEY_VAULT_NAME = os.environ['KEY_VAULT_NAME']
ORDER_SERVICE_FQDN = os.environ['ORDER_SERVICE_FQDN']

logging.basicConfig(level=logging.INFO)

app = Flask(__name__)
# The cart lives in the session, which is signed with this key. In Azure it is a Container App
# secret, so the cart survives a scale-to-zero cold start. The random fallback is for local runs only.
app.secret_key = os.environ.get('FLASK_SECRET_KEY') or secrets.token_hex(32)

key_vault_name = KEY_VAULT_NAME
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
    logging.info('Rendering index page')
    return render_template('index.html', specialties=specialties)

@app.route('/add_to_cart/<int:spec_id>')
def add_to_cart(spec_id):
    specialty = next((x for x in specialties if x["id"] == spec_id), None)
    if specialty:
        cart = session.get('cart', [])
        cart.append(specialty)
        session['cart'] = cart
        logging.info(f'Added specialty with id {spec_id} to cart')
    return redirect(url_for('index'))

@app.route('/remove_from_cart/<int:item_id>', methods=['POST'])
def remove_from_cart(item_id):
    cart = session.get('cart', [])
    cart = [item for item in cart if item['id'] != item_id]
    session['cart'] = cart
    logging.info(f'Removed item with id {item_id} from cart')
    return redirect(url_for('show_cart'))

@app.route('/cart')
def show_cart():
    cart = session.get('cart', [])
    logging.info('Rendering cart page')
    return render_template('cart.html', cart=cart)

@app.route('/checkout', methods=['POST'])
def checkout():
    cart = session.get('cart', [])
    cart = [{'id': item['id'], 'name': item['name'], 'price': item['price']} for item in cart]
    headers = {'X-API-Key': api_key}
    response = requests.post(f"{ORDER_SERVICE_FQDN}/order", json=cart, headers=headers)
    logging.info('Sent request')
    if response.status_code == 200:
        session['cart'] = []
        logging.info('Checkout successful')
    else:
        logging.error('Checkout failed with status code: %d', response.status_code)
    return redirect(url_for('show_cart'))

if __name__ == '__main__':
    logging.info('Starting Flask app')
    app.run(host='0.0.0.0', port=5000)
