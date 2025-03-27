import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/billing_provider.dart';
import '../models/product.dart';
import 'dart:typed_data';

class BillPreviewScreen extends StatelessWidget {
  const BillPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final billingProvider = Provider.of<BillingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Preview'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bill Summary',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ListView.builder(
                    itemCount: billingProvider.products.length,
                    itemBuilder: (context, index) {
                      final Product product = billingProvider.products[index];
                      return ListTile(
                        title: Text(
                          product.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '\$${product.price} x ${product.quantity} = \$${(product.price * product.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildSummaryTile('Subtotal', billingProvider.total, Colors.black),
            _buildSummaryTile('Discount', billingProvider.finalTotal < billingProvider.total 
              ? billingProvider.total - billingProvider.finalTotal 
              : 0, Colors.red),
            _buildSummaryTile('Tax', billingProvider.finalTotal > billingProvider.total 
              ? billingProvider.finalTotal - billingProvider.total 
              : 0, Colors.green),
            const Divider(thickness: 2),
            _buildSummaryTile('Final Total', billingProvider.finalTotal, Colors.blueAccent, isBold: true),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _printBill(context, billingProvider),
                icon: const Icon(Icons.print),
                label: const Text('Print & Export Bill'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTile(String label, double amount, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 18, fontWeight: isBold ? FontWeight.bold : FontWeight.w500),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 18, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }

  Future<void> _printBill(BuildContext context, BillingProvider billingProvider) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Supermarket Bill', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Item', 'Price', 'Qty', 'Total'],
                data: billingProvider.products.map((p) => [
                  p.name,
                  '\$${p.price}',
                  '${p.quantity}',
                  '\$${(p.price * p.quantity).toStringAsFixed(2)}'
                ]).toList(),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.Text('Subtotal: \$${billingProvider.total.toStringAsFixed(2)}', 
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('Discount: \$${(billingProvider.total - billingProvider.finalTotal).toStringAsFixed(2)}', 
                style: pw.TextStyle(fontSize: 16, color: PdfColors.red)),
              pw.Text('Tax: \$${(billingProvider.finalTotal - billingProvider.total).toStringAsFixed(2)}', 
                style: pw.TextStyle(fontSize: 16, color: PdfColors.green)),
              pw.Divider(),
              pw.Text('Final Total: \$${billingProvider.finalTotal.toStringAsFixed(2)}', 
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
            ],
          );
        },
      ),
    );

    try {
      final Uint8List pdfBytes = await pdf.save();
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
    } catch (e) {
      debugPrint("Error generating PDF: $e");
    }
  }
}
