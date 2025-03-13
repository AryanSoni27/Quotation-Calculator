import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/quotation_item.dart';

Future<void> generatePdf({
  required String customerName,
  required String date,
  required String projectName,
  required String mobileNumber,
  required String streetAddress,
  required String city,
  required String state,
  required String pinCode,
  required List<QuotationItem> items,
}) async {
  try {
    final pdf = pw.Document();

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
                      pw.Text("Customer : $customerName", style: pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 5),
                      pw.Text("Project : $projectName", style: pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 5),

                      // Address Formatting
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [

                          pw.Text("Address: $streetAddress,", style: pw.TextStyle(fontSize: 12, )),
                          pw.SizedBox(height: 1),

                          pw.Text("$city - $pinCode,", style: pw.TextStyle(fontSize: 12)),
                          pw.SizedBox(height: 1),

                          pw.Text(state, style: pw.TextStyle(fontSize: 12)),
                        ],
                      ),

                      pw.SizedBox(height: 5),
                      pw.Text("Mobile : $mobileNumber", style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),

                  pw.Text("Date : $date", style: pw.TextStyle(fontSize: 12)),
                ],
              ),

              pw.SizedBox(height: 10),

              // Quotation Table
              pw.TableHelper.fromTextArray(
                headers: ["S.No.", "Item", "Measurements", "Square Feet", "Quantity", "Rate", "Total"],
                headerStyle: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(color: PdfColors.blue),
                data: List.generate(
                  items.length,
                      (index) => [
                    ("${index + 1}"),
                    items[index].itemName,
                    "${items[index].length} × ${items[index].width}${items[index].height != null ? ' × ${items[index].height}' : ''} ${items[index].unit}",
                    (items[index].squareFeet.toStringAsFixed(2)),
                    (items[index].quantity.toString()),
                    (items[index].rate.toStringAsFixed(2)),
                    (items[index].totalCost.toStringAsFixed(2)),
                  ],
                ),
                border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
                cellStyle: pw.TextStyle(fontSize: 12),
                cellAlignments: {
                  0: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                  5: pw.Alignment.center,
                  6: pw.Alignment.center,
                },
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
