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
import 'package:path_provider/path_provider.dart';

Future<List<ClientDetails>> loadClients() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? clientJsonList = prefs.getStringList('client_list');

  if (clientJsonList != null) {
    return clientJsonList.map((jsonString) =>
        ClientDetails.fromJson(jsonDecode(jsonString))).toList();
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
  List<Quotation> _filteredQuotations = [];
  List<QuotationItem> items = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  int? _currentExpandedIndex;

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String> getPdfPath(String quotationId) async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/Quotation_${DateTime.now().millisecondsSinceEpoch}.pdf";
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to open PDF: $e")));
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
        _filteredQuotations = quotations;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading quotations: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterQuotations(String query) {
    setState(() {
      _filteredQuotations = _quotations.where((quotation) {
        final projectNameMatch = quotation.projectName.toLowerCase().contains(query.toLowerCase());
        final customerNameMatch = quotation.customerName.toLowerCase().contains(query.toLowerCase());
        return projectNameMatch || customerNameMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search Project...',
                hintStyle: TextStyle(color: isDarkMode ? Colors.white60 : Colors.black54),
                prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white60 : Colors.black54),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: isDarkMode ? Colors.white70 : Colors.black87),
                  onPressed: () {
                    _searchController.clear();
                    _filterQuotations('');
                  },
                )
                    : null,
              ),
              onChanged: _filterQuotations,
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredQuotations.isEmpty
                ? const Center(child: Text("No quotations found"))
                : ListView.builder(
              itemCount: _filteredQuotations.length,
              itemBuilder: (context, index) {
                final quotation = _filteredQuotations[index];
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
                  child: CustomExpansionTile(
                    // key: PageStorageKey(quotation.id),
                    initiallyExpanded: _currentExpandedIndex == index,
                    onExpansionChanged: (isExpanded) {
                      setState(() {
                        _currentExpandedIndex = isExpanded ? index : null;
                      });
                    },
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
                              future: getClientDetailsByName(quotation.customerName),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Text("Contact : Loading...",
                                      style: TextStyle(fontSize: 16));
                                }
                                if (!snapshot.hasData || snapshot.data == null) {
                                  return const Text("Contact : Not Available",
                                      style: TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold));
                                }
                                return Text(
                                  "Contact : ${snapshot.data!.countryCode} ${snapshot.data!.mobileNumber}",
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                );
                              },
                            ),

                            const SizedBox(height: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Items :",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.picture_as_pdf, color: Colors.blue),
                                      onPressed: () async {
                                        final pdfPath = await generateAndOpenPdf(quotation);
                                      },
                                      style: IconButton.styleFrom(
                                        backgroundColor: isDarkMode ? Colors.white12 : Colors.white,
                                        shape: const CircleBorder(),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        // Show confirmation dialog
                                        bool? confirmDelete = await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Confirm Delete'),
                                              content: const Text('Are you sure want to delete this estimation?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text('Cancel', style: TextStyle(color : isDarkMode ? Colors.white : Colors.black)),
                                                  onPressed: () {
                                                    Navigator.of(context).pop(false);
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                  onPressed: () {
                                                    Navigator.of(context).pop(true);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        // Proceed with deletion only if user confirms
                                        if (confirmDelete == true) {
                                          await DBHelperQuotation.instance.deleteQuotation(quotation.id);
                                          _loadQuotations();
                                        }
                                      },
                                      style: IconButton.styleFrom(
                                        backgroundColor: isDarkMode ? Colors.white12 : Colors.white,
                                        shape: const CircleBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 1),

                            Card(
                              color: isDarkMode ? Colors.white10 : Colors.white,
                              margin: const EdgeInsets.all(8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: quotation.items.map((item) {
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    item.itemName,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Text(
                                                    item.unit == "N/A"
                                                        ? "Area: N/A"
                                                        : item.unit == "R. Foot"
                                                        ? "Area: ${item.foot} ${item.unit}"
                                                        : 'Area: (${item.length} × ${item.width}${item.height != null ? ' × ${item.height}' : ''} ${item.unit})',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text("Qty: ${item.quantity}"),
                                                  Text("Rate: ₹${item.rate.toStringAsFixed(2)}"),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    "Total: ₹${NumberFormat("#,##0.00").format(item.totalCost)}",
                                                    style: const TextStyle(
                                                      color: Colors.blueAccent,
                                                    ),
                                                  ),
                                                  Text(
                                                      item.unit == "N/A"
                                                          ? "Sq. Feet: N/A"
                                                          : 'Sq. Feet: ${item.squareFeet.toStringAsFixed(2)}'
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),

                                        if (quotation.items.last != item)
                                          Divider(
                                            color: Colors.grey.shade400,
                                            thickness: 0.8,
                                          ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Custom ExpansionTile to manage single expansion
class CustomExpansionTile extends StatefulWidget {
  final Widget title;
  final Widget? subtitle;
  final List<Widget> children;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final Key? key;

  const CustomExpansionTile({
    this.key,
    required this.title,
    this.subtitle,
    this.children = const [],
    this.initiallyExpanded = false,
    this.onExpansionChanged,
  }) : super(key: key);

  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _isExpanded = widget.initiallyExpanded;
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
    _updateAnimation();
  }

  @override
  void didUpdateWidget(CustomExpansionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initiallyExpanded != _isExpanded) {
      _isExpanded = widget.initiallyExpanded;
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted) return;
        });
      }
      widget.onExpansionChanged?.call(_isExpanded);
    });
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          title: widget.title,
          subtitle: widget.subtitle,
          onTap: _handleTap,
          trailing: RotationTransition(
            turns: Tween<double>(begin: 0.0, end: 0.5).animate(_controller),
            child: const Icon(Icons.expand_more),
          ),
        ),
        ClipRect(
          child: Align(
            alignment: Alignment.center,
            heightFactor: _heightFactor.value,
            child: child,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: widget.children.isNotEmpty
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.children,
      )
          : null,
    );
  }
}