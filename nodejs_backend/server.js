const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const app = express();
const port = 5000;

app.use(cors());
app.use(bodyParser.json());

let products = [];

// Get all products
app.get('/products', (req, res) => {
    res.json(products);
});

// Add a product
app.post('/products', (req, res) => {
    const { name, price, quantity } = req.body;
    if (!name || price == null || quantity == null) {
        return res.status(400).json({ error: 'Missing product details' });
    }
    const newProduct = { id: products.length + 1, name, price, quantity };
    products.push(newProduct);
    res.status(201).json(newProduct);
});

// Remove a product
app.delete('/products/:id', (req, res) => {
    const id = parseInt(req.params.id);
    products = products.filter(product => product.id !== id);
    res.json({ message: 'Product removed' });
});

// Generate and export bill
app.post('/generate-bill', (req, res) => {
    const total = products.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    const bill = {
        items: products,
        total: total.toFixed(2),
        timestamp: new Date().toISOString()
    };
    res.json(bill);
});

app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});
