import 'dart:io';
import 'dart:typed_data';
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
}) async {
  try {
    final pdf = pw.Document();

    // Load custom font
    pw.Font? ttf;
    try {
      final fontData = await rootBundle.load(
        "assets/fonts/OpenSans-Regular.ttf",
      );
      ttf = pw.Font.ttf(fontData.buffer.asByteData());
    } catch (e) {
      print("Error fetching font");
    }

    // Calculate grand total
    double grandTotal = items.fold(0.0, (sum, item) => sum + item.totalCost);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Title
              pw.Text(
                "ESTIMATE",
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.Divider(thickness: 2, color: PdfColors.blue),
              pw.SizedBox(height: 10),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Customer Name: $customerName",
                        style: pw.TextStyle(fontSize: 12, font: ttf),
                      ),
                      pw.Text(
                        "Project Name: $projectName",
                        style: pw.TextStyle(fontSize: 12, font: ttf),
                      ),
                      pw.Text(
                        "Mobile: $mobileNumber",
                        style: pw.TextStyle(fontSize: 12, font: ttf),
                      ),
                    ],
                  ),


                  pw.Text(
                    "Date: $date",
                    style: pw.TextStyle(fontSize: 12, font: ttf),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              //Quotation Table
              pw.TableHelper.fromTextArray(
                headers: [
                  "S.No.",
                  "Item",
                  "Measurements",
                  "Square Feet",
                  "Quantity",
                  "Rate",
                  "Total",
                ],
                headerStyle: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(color: PdfColors.blue),
                data: List.generate(
                  items.length,
                  (index) => [
                    ("${index + 1}"),
                    items[index].itemName,
                    "${items[index].length} × ${items[index].width}${items[index].height != null ? ' × ${items[index].height}' : ''} ${items[index].unit}",
                    "${(items[index].squareFeet.toStringAsFixed(2))} sq ft",
                    (items[index].quantity.toString()),
                    (items[index].rate.toStringAsFixed(2)),
                    (items[index].totalCost.toStringAsFixed(2)),
                  ],
                ),
                border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
                cellStyle: pw.TextStyle(fontSize: 12, font: ttf),
                // cellAlignment: <int, pw.Alignment>{
                //   0: pw.Alignment.center,
                // },
              ),

              pw.SizedBox(height: 10),

              // Grand Total
              pw.Container(
                padding: pw.EdgeInsets.all(8),
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "Grand Total: ${grandTotal.toStringAsFixed(2)}",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save PDF
    final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/quotation.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Open PDF
    OpenFile.open(filePath);
  } catch (e) {
    print("Error generating PDF: $e");
  }
}
