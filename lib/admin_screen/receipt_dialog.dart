
import 'package:flutter/material.dart';
import 'package:sales_managementv5/model/orderitem_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class ReceiptDialog extends StatefulWidget {
  final String customerName;
  final String tableNumber;
  final List<OrderItem> orders;
  final double totalPrice;
  final int orderNumber;

  const ReceiptDialog({
    Key? key,
    required this.customerName,
    required this.tableNumber,
    required this.orders,
    required this.totalPrice,
    required this.orderNumber,
  }) : super(key: key);

  @override
  State<ReceiptDialog> createState() => _ReceiptDialogState();
}

class _ReceiptDialogState extends State<ReceiptDialog> {
  late final pw.Document pdf;

  @override
  void initState() {
    super.initState();
    pdf = _generatePdf();
  }

  pw.Document _generatePdf() {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text('Receipt', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 12),
                pw.Text('Order Number: ${widget.orderNumber}', style: pw.TextStyle(fontSize: 16)),
                pw.Text('Customer Name: ${widget.customerName}', style: pw.TextStyle(fontSize: 16)),
                pw.Text('Table Number: ${widget.tableNumber}', style: pw.TextStyle(fontSize: 16)),
                pw.Divider(),
                pw.Text('Orders:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Column(
                  children: widget.orders.map((order) {
                    final itemTotal = order.price * order.quantity;
                    return pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Text('${order.menuName} x${order.quantity}', style: pw.TextStyle(fontSize: 16)),
                        ),
                        pw.Text('₱${itemTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16)),
                      ],
                    );
                  }).toList(),
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.Text('₱${widget.totalPrice.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  Future<void> _printReceipt() async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          children: [
            const Center(
              child: Text(
                'Receipt',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: PdfPreview(
                build: (format) => pdf.save(),
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
                initialPageFormat: PdfPageFormat.a4,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _printReceipt,
                  icon: const Icon(Icons.print),
                  label: const Text('Print'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
