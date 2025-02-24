import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'main.dart';

class FormController {
  TextEditingController customerNameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController projectNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();

  void dispose() {
    customerNameController.dispose();
    dateController.dispose();
    projectNameController.dispose();
    mobileNumberController.dispose();
  }
}

Future<void> generatePdf({
  required String customerName,
  required String date,
  required String projectName,
  required String mobileNumber,
  required List<QuotationItem> items,
})async {
  // Create a PDF document
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Quotation", style: pw.TextStyle(
                fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),

            pw.Text("Customer Name: $customerName"),
            pw.Text("Date: $date"),
            pw.Text("Project Name: $projectName"),
            pw.Text("Mobile Number: $mobileNumber"),
            pw.SizedBox(height: 20),

            pw.Text("Added Items:", style: pw.TextStyle(
                fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),

            pw.TableHelper.fromTextArray(
              headers: ["Item Name", "Measurements", "Rate", "Total Cost"],
              data: items.map((item) =>
              [
                item.itemName,
                "${item.length} × ${item.width}${item.height != null
                    ? ' × ${item.height}'
                    : ''} ${item.unit}",
                item.rate.toStringAsFixed(2),
                item.totalCost.toStringAsFixed(2)
              ]).toList(),
            ),
          ],
        );
      },
    ),
  );
  final pdfBytes = await pdf.save();
  final directory = await getApplicationDocumentsDirectory();
  final filePath = "${directory.path}/quotation.pdf";
  final file = File(filePath);
  await file.writeAsBytes(pdfBytes);

  OpenFile.open(filePath);
}