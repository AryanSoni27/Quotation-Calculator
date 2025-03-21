import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

    // Get user information from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString('firstName') ?? "";
    final lastName = prefs.getString('lastName') ?? "";
    final userMobileNumber = prefs.getString('mobileNumber') ?? "";

    String formattedDate;
    try {
      // Parse the input date which is in format dd/MM/yyyy
      DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(date);

      // Format to dd-MMM-yyyy with month in uppercase
      String tempFormatted = DateFormat('dd-MMM-yyyy').format(parsedDate);

      // Convert the month part to uppercase
      List<String> parts = tempFormatted.split('-');
      if (parts.length == 3) {
        parts[1] = parts[1].toUpperCase();
        formattedDate = parts.join('-');
      } else {
        formattedDate = tempFormatted;
      }
    } catch (e) {
      // If parsing fails, use the original string
      formattedDate = date;
      print("Failed to format date: $e");
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
                        "Customer : $customerName",
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        "Project : $projectName",
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 5),

                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.RichText(
                            text: pw.TextSpan(
                              children: [
                                pw.TextSpan(
                                  text: "Address : ",
                                  style: pw.TextStyle(fontSize: 12),
                                ),
                                pw.TextSpan(
                                  text: "$streetAddress,",
                                  style: pw.TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.SizedBox(width: 54),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    "$city - $pinCode,",
                                    style: pw.TextStyle(fontSize: 12),
                                  ),
                                  pw.Text(
                                    "$state.",
                                    style: pw.TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                      pw.SizedBox(height: 5),
                      pw.Text(
                        "Mobile : $mobileNumber",
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),

                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "Date : $formattedDate",
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        "Given By : $firstName $lastName",
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        "Mobile : $userMobileNumber",
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // Quotation Table
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
                    items[index].unit == "N/A"
                        ? "N/A"
                        : (items[index].unit == "R. Foot"
                        ? "R. Foot"
                        : "${items[index].length} × ${items[index].width}${items[index].height != null ? ' × ${items[index].height}' : ''} ${items[index].unit}"),
                    items[index].unit == "N/A"
                        ? "N/A":
                        (items[index].squareFeet.toStringAsFixed(2)),
                    (items[index].quantity.toString()),
                    (items[index].rate.toStringAsFixed(2)),
                    NumberFormat("#,##0.00").format(items[index].totalCost),
                  ],
                ),
                border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
                cellStyle: pw.TextStyle(fontSize: 12),
                cellAlignments: {
                  0: pw.Alignment.center,
                  2: pw.Alignment.center,
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
                  "Grand Total: ${NumberFormat("#,##0.00").format(grandTotal)}",
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
