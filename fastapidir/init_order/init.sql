CREATE TABLE IF NOT EXISTS Orders
(
    id SERIAL PRIMARY KEY,
    product_id TEXT,
    quantity INTEGER
);

INSERT INTO Orders (product_id, quantity) VALUES
('product1', 10),
('product2', 20),
('product3', 30),
('product4', 40),
('product5', 50),
('product6', 60),
('product7', 70),
('product8', 80),
('product9', 90),
('product10', 100)
ON CONFLICT DO NOTHING;
