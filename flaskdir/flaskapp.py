from flask import Flask, request, jsonify
from psycopg2 import sql
import psycopg2

app = Flask(__name__)

# Database connection parameters
db_params = {
    'dbname': 'product_db',
    'user': 'petbell',
    'password': 'i12pose',
    'host': 'product_db',
    'port': '5432'
}

@app.route('/')
def index():
    return "Welcome to the Product API!"

@app.route('/products', methods=['GET'])
def get_products():
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()

        # Execute a query to fetch all products
        query = sql.SQL("SELECT * FROM products")
        cursor.execute(query)

        # Fetch all results
        products = cursor.fetchall()

        # Close the cursor and connection
        cursor.close()
        conn.close()

        # Return the products as a JSON response
        return {'products': products}, 200

    except Exception as e:
        return {'error': str(e)}, 500
    
@app.route('/products', methods=['POST'])
def add_product ():
    data = request.get_json()
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()

        # Insert a new product into the database
        query = sql.SQL("INSERT INTO products (name, price) VALUES (%s, %s) RETURNING id")
        cursor.execute(query, (data['name'], data['price']))
        product_id = cursor.fetchone()[0]

        # Commit the transaction and close the connection
        conn.commit()
        cursor.close()
        conn.close()

        return {'id': product_id}, 201
    except Exception as e:
        return {'error': str(e)}, 500
        
    
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)