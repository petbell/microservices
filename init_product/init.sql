-- Create the table
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    price NUMERIC NOT NULL
);

-- Insert test data
INSERT INTO products (name, price) VALUES
('Poultry Feed', 5000.00),
('Fish Feed', 3500.00),
('Antibiotic - Amoxicillin', 1200.00),
('Dog Vaccine', 4500.00)
ON CONFLICT DO NOTHING;

