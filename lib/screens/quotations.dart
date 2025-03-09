import 'package:flutter/material.dart';
import '../models/quotation_screen.dart';
import '../models/quotation_item.dart';
import '../data/db_helper_quotation_screen.dart';
import '../services/pdf_generator.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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

  @override
  void initState() {
    super.initState();
    _loadQuotations();
  }

  Future<String> getPdfPath(String quotationId) async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/Quotation_${DateTime.now().millisecondsSinceEpoch}.pdf"; // Ensure it matches the saved filename
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Quotations"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _quotations.isEmpty
          ? const Center(child: Text("No quotations found"))
          : ListView.builder(
        itemCount: _quotations.length,
        itemBuilder: (context, index) {
          final quotation = _quotations[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
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
                  Text("Total: ₹${quotation.totalAmount.toStringAsFixed(2)}"),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
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
                      ...quotation.items.map((item) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.itemName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${item.length} × ${item.width}${item.height != null ? ' × ${item.height}' : ''} ${item.unit}',
                              ),
                              Text(
                                'Area: ${item.squareFeet.toStringAsFixed(2)} sq ft',
                              ),
                              Text('Quantity: ${item.quantity}'),
                              Text('Rate: ₹${item.rate.toStringAsFixed(2)}'),
                              Text(
                                'Total: ₹${item.totalCost.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      )),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // ElevatedButton.icon(
                          //   onPressed: () async {
                          //
                          //   },
                          //   icon: const Icon(Icons.visibility),
                          //   label: const Text("View PDF"),
                          // ),

                          ElevatedButton.icon(
                            onPressed: () async {
                              await DBHelperQuotation.instance.deleteQuotation(quotation.id);
                              _loadQuotations();
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text("Delete"),
                            style: ElevatedButton.styleFrom(
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
        onPressed: _loadQuotations,
        label: const Text("Refresh"),
        icon: const Icon(Icons.refresh),
      ),
    );
  }
}