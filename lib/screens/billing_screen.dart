import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/billing_provider.dart';
import '../services/api_service.dart';
import 'bill_preview_screen.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  _BillingScreenState createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController taxController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supermarket Billing', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInputField(nameController, 'Product Name', Icons.shopping_bag),
            _buildInputField(priceController, 'Price', Icons.attach_money, isNumeric: true),
            _buildInputField(quantityController, 'Quantity', Icons.confirmation_number, isNumeric: true),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              onPressed: _addProduct,
            ),
            const SizedBox(height: 20),
            Consumer<BillingProvider>(
              builder: (context, billingProvider, child) {
                return Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: billingProvider.products.length,
                      itemBuilder: (context, index) {
                        final product = billingProvider.products[index];
                        return _buildProductCard(product, index);
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildInputField(discountController, 'Discount (%)', Icons.discount, isNumeric: true, onChanged: (value) {
                      billingProvider.setDiscount(double.tryParse(value) ?? 0.0);
                    }),
                    _buildInputField(taxController, 'Tax (%)', Icons.percent, isNumeric: true, onChanged: (value) {
                      billingProvider.setTax(double.tryParse(value) ?? 0.0);
                    }),
                    Text(
                      'Total: \$${billingProvider.finalTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BillPreviewScreen()),
                        );
                      },
                      child: const Text('Preview Bill'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, IconData icon, {bool isNumeric = false, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildProductCard(Product product, int index) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Price: \$${product.price} x ${product.quantity}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editProduct(context, product, index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await ApiService.deleteProduct(product.id!);
                Provider.of<BillingProvider>(context, listen: false).fetchProducts();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addProduct() async {
    String name = nameController.text;
    double price = double.tryParse(priceController.text) ?? 0.0;
    int quantity = int.tryParse(quantityController.text) ?? 1;
    if (name.isNotEmpty && price > 0) {
      Product newProduct = Product(name: name, price: price, quantity: quantity);
      await ApiService.addProduct(newProduct);
      Provider.of<BillingProvider>(context, listen: false).fetchProducts();
      nameController.clear();
      priceController.clear();
      quantityController.clear();
    }
  }

  void _editProduct(BuildContext context, Product product, int index) {
    nameController.text = product.name;
    priceController.text = product.price.toString();
    quantityController.text = product.quantity.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInputField(nameController, 'Product Name', Icons.shopping_bag),
            _buildInputField(priceController, 'Price', Icons.attach_money, isNumeric: true),
            _buildInputField(quantityController, 'Quantity', Icons.confirmation_number, isNumeric: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ApiService.updateProduct(
                Product(
                  id: product.id,
                  name: nameController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  quantity: int.tryParse(quantityController.text) ?? 1,
                ),
              );
              Provider.of<BillingProvider>(context, listen: false).fetchProducts();
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
