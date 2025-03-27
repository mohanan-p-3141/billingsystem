import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/product.dart';

class PDFService {
  static Future<File> generateBill(List<Product> products, double total) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Supermarket Bill', style: pw.TextStyle(fontSize: 24)),
              pw.Divider(),
              ...products.map((p) => pw.Text('${p.name} - \$${p.price} x ${p.quantity}')),
              pw.Divider(),
              pw.Text('Total: \$${total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/bill.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
