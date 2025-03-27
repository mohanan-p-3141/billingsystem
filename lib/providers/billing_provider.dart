import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class BillingProvider extends ChangeNotifier {
  List<Product> _products = [];
  double _discount = 0.0;
  double _tax = 0.0;

  List<Product> get products => _products;
  double get total => _products.fold(0, (sum, item) => sum + item.totalPrice);
  double get discount => _discount;
  double get tax => _tax;

  Future<void> fetchProducts() async {
    _products = await ApiService.fetchProducts();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await ApiService.addProduct(product);
    fetchProducts(); // Refresh list after adding
  }

  Future<void> removeProduct(int index) async {
    if (_products[index].id != null) {
      await ApiService.deleteProduct(_products[index].id!);
    }
    fetchProducts(); // Refresh list after deletion
  }

  Future<void> updateProduct(int index, String name, double price, int quantity) async {
    Product updatedProduct = Product(name: name, price: price, quantity: quantity);
    await ApiService.addProduct(updatedProduct);
    fetchProducts(); // Refresh list after updating
  }

  void setDiscount(double discount) {
    _discount = discount;
    notifyListeners();
  }

  void setTax(double tax) {
    _tax = tax;
    notifyListeners();
  }

  double get finalTotal {
    double totalAmount = total;
    double discountAmount = (totalAmount * _discount) / 100;
    double taxedAmount = ((totalAmount - discountAmount) * _tax) / 100;
    return totalAmount - discountAmount + taxedAmount;
  }
}
