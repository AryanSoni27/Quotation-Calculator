import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../models/client_details.dart';
import '../models/quotation_screen.dart';
import '../models/quotation_item.dart';
import '../data/db_helper_quotation_screen.dart';
import '../services/pdf_generator.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<List<ClientDetails>> loadClients() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? clientJsonList = prefs.getStringList('client_list');

  if (clientJsonList != null) {
    return clientJsonList.map((jsonString) => ClientDetails.fromJson(jsonDecode(jsonString))).toList();
  }
  return [];
}

class Quotations extends StatefulWidget {
  const Quotations({super.key});

  @override
  _QuotationsState createState() => _QuotationsState();
}

class _QuotationsState extends State<Quotations> {
  final FormController formController = FormController();
  List<Quotation> _quotations = [];
  List<QuotationItem> items = [];
  bool _isLoading = true;

  Future<ClientDetails?> getClientDetailsByName(String customerName) async {
    List<ClientDetails> clients = await loadClients(); // Load client list first
    for (var client in clients) {
      String fullName = "${client.firstName} ${client.lastName}";
      if (fullName.toLowerCase() == customerName.toLowerCase()) {
        return client;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadQuotations();
  }

  Future<String> getPdfPath(String quotationId) async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/Quotation_${DateTime.now().millisecondsSinceEpoch}.pdf"; // Ensure it matches the saved filename
  }

  Future<String?> generateAndOpenPdf(Quotation quotation) async {
    try {
      ClientDetails? client = await getClientDetailsByName(quotation.customerName);

      String rawDate = quotation.date;
      String formattedDate;

      try {
        DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(rawDate);

        String tempFormatted = DateFormat('dd-MMM-yyyy').format(parsedDate);

        List<String> parts = tempFormatted.split('-');
        if (parts.length == 3) {
          parts[1] = parts[1].toUpperCase();
          formattedDate = parts.join('-');
        } else {
          formattedDate = tempFormatted;
        }
      } catch (e) {

        formattedDate = rawDate;
        print("Failed to format date: $e");
      }

      await generatePdf(
        customerName: quotation.customerName,
        date: formattedDate,
        projectName: quotation.projectName,
        mobileNumber: client != null ? "${client.countryCode} ${client.mobileNumber}" : quotation.mobileNumber,
        streetAddress: client?.streetAddress ?? "N/A",
        city: client?.city ?? "N/A",
        state: client?.state ?? "N/A",
        pinCode: client?.pinCode ?? "N/A",
        items: quotation.items,
      );
      return null;
    } catch (e) {
      print("Error opening PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to open PDF: $e")));
      return null;
    }
  }

  Future<void> _loadQuotations() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final quotations = await DBHelperQuotation.instance.getAllQuotations();
      print("Loaded ${quotations.length} quotations");
      setState(() {
        _quotations = quotations;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading quotations: $e");
      setState(() {
        _isLoading = false;
        // Show error state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    // ClientDetails? client = await getClientDetailsByName(quotation.customerName);
    return Scaffold(
      // appBar: AppBar(title: const Text("Saved Estimations")),
      body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _quotations.isEmpty
              ? const Center(child: Text("No quotations found"))
              : ListView.builder(
                itemCount: _quotations.length,
                itemBuilder: (context, index) {
                  final quotation = _quotations[index];
                  return Card(
                    margin: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 10,
                    ),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        quotation.projectName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Customer : ${quotation.customerName}"),
                          Text("Date : ${quotation.date}"),
                          Text(
                            "Total : ₹${NumberFormat("#,##0.00").format(quotation.totalAmount)}",
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            bottom: 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder<ClientDetails?>(
                                future: getClientDetailsByName(quotation.customerName), // Fetch client details
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Text("Contact : Loading...", style: TextStyle(fontSize: 16));
                                  }
                                  if (!snapshot.hasData || snapshot.data == null) {
                                    return const Text("Contact : Not Available", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
                                  }
                                  return Text(
                                    "Contact : ${snapshot.data!.countryCode} ${snapshot.data!.mobileNumber}",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  );
                                },
                              ),

                              const SizedBox(height: 8),
                              const Text(
                                "Items :",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),

                              //List of items
                              Column(
                                children:
                                    quotation.items.map((item) {
                                      return Card(
                                        color: isDarkMode ? Colors.white10 : Colors.white,
                                        margin: const EdgeInsets.only(
                                          bottom: 12.0,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    item.itemName,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Area: ${item.squareFeet.toStringAsFixed(2)} sq ft'
                                                        '${item.unit == "R. Foot" ? "" : " (${item.length} × ${item.width}${item.height != null ? ' × ${item.height}' : ''} ${item.unit})"}',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),

                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text("Qty: ${item.quantity}"),
                                                  Text(
                                                    "Rate: ₹${item.rate.toStringAsFixed(2)}",
                                                  ),
                                                  Text(
                                                    "Total: ₹${NumberFormat("#,##0.00").format(item.totalCost)}",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final pdfPath = await generateAndOpenPdf(
                                        quotation,
                                      );
                                    },
                                    icon: const Icon(Icons.picture_as_pdf, color: Colors.blue),
                                    label: const Text("PDF"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDarkMode ? Colors.white12 : Colors.white,
                                      foregroundColor: Colors.blue,
                                    ),
                                  ),

                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      await DBHelperQuotation.instance
                                          .deleteQuotation(quotation.id);
                                      _loadQuotations();
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    label: const Text("Delete"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDarkMode ? Colors.white12 : Colors.white,
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      // floatingActionButton: FloatingActionButton.extended(
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      //   onPressed: _loadQuotations,
      //   backgroundColor: Colors.white,
      //   icon: Icon(Icons.refresh, color: Colors.blue),
      //   label: Text(
      //     "Refresh",
      //     style: TextStyle(color: Colors.black, fontSize: 16),
      //   ),
      // ),
    );
  }
}
