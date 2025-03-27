import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onRemove;

  const ProductTile({super.key, required this.product, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${product.name} - \$${product.price} x ${product.quantity}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onRemove,
      ),
    );
  }
}
