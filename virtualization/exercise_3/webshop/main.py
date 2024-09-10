from flask import Flask, render_template, request, redirect, url_for, session

app = Flask(__name__)
app.secret_key = 'a4d2a7a679c84dd792a5f5d6dd7a5792'

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
        # Get the cart from the session, or an empty list if there is no cart in the session.
        cart = session.get('cart', [])
        # Add the specialty to the cart.
        cart.append(specialty)
        # Store the cart back in the session.
        session['cart'] = cart
    return redirect(url_for('index'))

@app.route('/remove_from_cart/<int:item_id>', methods=['POST'])
def remove_from_cart(item_id):
    # Get the cart from the session.
    cart = session.get('cart', [])
    # Remove the item from the cart.
    cart = [item for item in cart if item['id'] != item_id]
    # Store the cart back in the session.
    session['cart'] = cart
    return redirect(url_for('show_cart'))

@app.route('/cart')
def show_cart():
    # Get the cart from the session.
    cart = session.get('cart', [])
    return render_template('cart.html', cart=cart)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
