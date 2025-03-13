import 'dart:convert';

import 'package:flutter/material.dart';
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
      await generatePdf(
        customerName: quotation.customerName,
        date: quotation.date,
        projectName: quotation.projectName,
        mobileNumber: client != null ? client.mobileNumber : quotation.mobileNumber,
        address: client != null ? "${client.streetAddress}, ${client.city}, ${client.state}" : "N/A", // Correct address
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

    final quotations = await DBHelperQuotation.instance.getAllQuotations();

    setState(() {
      _quotations = quotations;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
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
                          Text("Customer: ${quotation.customerName}"),
                          Text("Date: ${quotation.date}"),
                          Text(
                            "Total: ₹${quotation.totalAmount.toStringAsFixed(2)}",
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
                              Text(
                                "Contact: ${quotation.mobileNumber}",
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Items:",
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
                                                    "Area: ${item.squareFeet.toStringAsFixed(2)} sq ft (${item.length} × ${item.width}${item.height != null ? ' × ${item.height}' : ''} ${item.unit})",
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
                                                    "Total: ₹${item.totalCost.toStringAsFixed(2)}",
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
      floatingActionButton: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed: _loadQuotations,
        backgroundColor: Colors.white,
        icon: Icon(Icons.refresh, color: Colors.blue),
        label: Text(
          "Refresh",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
    );
  }
}
