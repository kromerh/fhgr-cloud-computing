from flask import Flask, render_template, request, redirect, url_for

app = Flask(__name__)

# List of food specialties
specialties = [
    {"id": 1, "name": "Bündner Nusstorte", "price": 20.00},
    {"id": 2, "name": "Capuns", "price": 15.00},
    {"id": 3, "name": "Pizokel", "price": 12.00},
    {"id": 4, "name": "Maluns", "price": 10.00},
    {"id": 5, "name": "Bündnerfleisch", "price": 30.00},
]

# Shopping cart
cart = []

@app.route('/')
def index():
    return render_template('index.html', specialties=specialties)

@app.route('/add_to_cart/<int:spec_id>')
def add_to_cart(spec_id):
    # Find the specialty by id
    specialty = next((x for x in specialties if x["id"] == spec_id), None)
    # Add to cart
    if specialty:
        cart.append(specialty)
    return redirect(url_for('index'))

@app.route('/cart')
def show_cart():
    return render_template('cart.html', cart=cart)

if __name__ == '__main__':
    app.run(debug=True)
