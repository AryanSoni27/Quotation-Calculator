import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quotation/data/db_helper_quotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/db_helper_quotation_screen.dart';
import '../main.dart';
import '../models/client_details.dart';
import '../models/quotation_item.dart';
import '../models/quotation_screen.dart';
import '../util/date_picker.dart';
import '../services/pdf_generator.dart';
import '../widgets/bottom_popup_quotation_item.dart';
import 'package:uuid/uuid.dart';

Future<List<ClientDetails>> loadClientsAddress() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? clientJsonList = prefs.getStringList('client_list');

  if (clientJsonList != null) {
    return clientJsonList.map((jsonString) => ClientDetails.fromJson(jsonDecode(jsonString))).toList();
  }
  return [];
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCustomerMobileNumber = "";
  final FormController formController = FormController();
  List<QuotationItem> items = [];
  List<Map<String, dynamic>> allQuotationItems = [];
  DBHelper dbRef = DBHelper.instance;

  List<ClientDetails> clients = [];

  bool _customerNameValid = true;
  bool _dateValid = true;
  bool _projectNameValid = true;
  // bool _mobileNumberValid = true;

  String selectedCustomer = "";

  final FocusNode _customerNameFocusNode = FocusNode();
  final FocusNode _dateFocusNode = FocusNode();
  final FocusNode _projectNameFocusNode = FocusNode();
  // final FocusNode _mobileNumberFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    getQuotationItems();
    loadCustomerDetails();
    setupTextFieldListeners();
    _setupFocusListeners();
    loadClients();
    loadSelectedClient();
  }

  Future<ClientDetails?> getClientDetailsByName(String customerName) async {
    List<ClientDetails> clients = await loadClientsAddress();
    for (var client in clients) {
      String fullName = "${client.firstName} ${client.lastName}";
      if (fullName.toLowerCase() == customerName.toLowerCase()) {
        return client;
      }
    }
    return null;
  }

  Future<void> loadClients() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? clientJsonList = prefs.getStringList('client_list');

    if (clientJsonList != null) {
      setState(() {
        clients =
            clientJsonList.map((jsonString) => ClientDetails.fromJson(jsonDecode(jsonString)),).toList();
      });
    }
  }

  Future<void> loadSelectedClient() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedName = prefs.getString('selected_customer');
    String? savedMobile = prefs.getString('selected_mobile');

    if (savedName != null && savedMobile != null) {
      setState(() {
        formController.customerNameController.text = savedName;
        selectedCustomerMobileNumber = savedMobile;
      });
    }
  }

  Future<void> saveSelectedClient(String name, String mobile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_customer', name);
    await prefs.setString('selected_mobile', mobile);
  }

  Future<void> loadCustomerDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      formController.customerNameController.text = prefs.getString('customer_name') ?? '';
      formController.mobileNumberController.text = prefs.getString('mobile_number') ?? '';
      formController.projectNameController.text = prefs.getString('project_name') ?? '';
      formController.dateController.text = prefs.getString('date') ?? '';
    });
  }

  Future<void> saveCustomerDetails(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  void setupTextFieldListeners() {
    formController.customerNameController.addListener(() {
      saveCustomerDetails(
        'customer_name',
        formController.customerNameController.text,
      );
    });

    formController.mobileNumberController.addListener(() {
      saveCustomerDetails(
        'mobile_number',
        formController.mobileNumberController.text,
      );
    });

    formController.projectNameController.addListener(() {
      saveCustomerDetails(
        'project_name',
        formController.projectNameController.text,
      );
    });

    formController.dateController.addListener(() {
      saveCustomerDetails('date', formController.dateController.text);
    });
  }

  //Get all quotation items from database
  //Updated method to get all quotation items from database
  void getQuotationItems() async {
    List<Map<String, dynamic>> data = await dbRef.getAllQuotationItems();

    List<QuotationItem> fetchedItems =
    data.map((item) {
      return QuotationItem(
        id: item['s_no'],
        // Ensure ID is retrieved
        itemName: item['item_name'],
        unit: item['unit'],
        shape: item['shape'],
        length: item['length'] != null ? (item['length'] as num).toDouble() : null,
        width: item['width'] != null ? (item['width'] as num).toDouble() : null,
        height: item['height'] != null ? (item['height'] as num).toDouble() : null,
        squareFeet: (item['square_feet'] as num).toDouble(),
        quantity: item['quantity'] as int,
        rate: (item['rate'] as num).toDouble(),
        totalCost: (item['total_cost'] as num).toDouble(),
        foot: item['foot'] != null ? (item['foot'] as num).toDouble() : null,

      );
    }).toList();

    setState(() {
      items = fetchedItems; // Update UI with persistent data
    });
  }

  // Add a quotation item to database
  Future<void> addQuotationItem(QuotationItem item) async {
    Map<String, dynamic> row = {
      DBHelper.COLUMN_SNO: item.id, // Store the ID in the database
      DBHelper.COLUMN_ITEM_NAME: item.itemName,
      DBHelper.COLUMN_UNIT: item.unit,
      if (item.shape != null) DBHelper.COLUMN_SHAPE: item.shape,
      if (item.length != null) DBHelper.COLUMN_LENGTH: item.length,
      if (item.width != null) DBHelper.COLUMN_WIDTH: item.width,
      if (item.height != null) DBHelper.COLUMN_HEIGHT: item.height,
      if (item.foot != null) DBHelper.COLUMN_FOOT: item.foot,
      DBHelper.COLUMN_SQUARE_FEET: item.squareFeet,
      DBHelper.COLUMN_QUANTITY: item.quantity,
      DBHelper.COLUMN_RATE: item.rate,
      DBHelper.COLUMN_TOTAL_COST: item.totalCost,

    };

    await dbRef.insertQuotationItem(row); // Insert into database

    getQuotationItems(); // Reload items from database to ensure persistence
  }

  // Update a quotation item in database
  Future<void> updateQuotationItem(QuotationItem oldItem, QuotationItem newItem) async {
    Map<String, dynamic> updatedValues = {
      DBHelper.COLUMN_ITEM_NAME: newItem.itemName,
      DBHelper.COLUMN_UNIT: newItem.unit,
      if (newItem.shape != null) DBHelper.COLUMN_SHAPE: newItem.shape,
      if (newItem.length != null) DBHelper.COLUMN_LENGTH: newItem.length,
      if (newItem.width != null) DBHelper.COLUMN_WIDTH: newItem.width,
      if (newItem.height != null) DBHelper.COLUMN_HEIGHT: newItem.height,
      if (newItem.foot != null) DBHelper.COLUMN_FOOT: newItem.foot,
      DBHelper.COLUMN_SQUARE_FEET: newItem.squareFeet,
      DBHelper.COLUMN_QUANTITY: newItem.quantity,
      DBHelper.COLUMN_RATE: newItem.rate,
      DBHelper.COLUMN_TOTAL_COST: newItem.totalCost,
    };

    await dbRef.updateQuotationItem(
      oldItem.itemName,
      oldItem.unit,
      oldItem.shape ?? '',
      oldItem.length ?? 0,
      oldItem.width ?? 0,
      oldItem.height,
      oldItem.foot,
      oldItem.squareFeet,
      oldItem.quantity,
      oldItem.rate,
      oldItem.totalCost,
      updatedValues,
    );

    print("Item is updating");

    setState(() {
      int index = items.indexWhere((item) => item.id == oldItem.id);
      if (index != -1) {
        items[index] = newItem;  // Update item in the UI list
      }
    });

    getQuotationItems(); // Refresh UI
  }



  // Delete a quotation item from database
  Future<void> deleteQuotationItem(int id) async {
    await dbRef.deleteQuotationItem(id); // Delete item from database

    setState(() {
      items.removeWhere((item) => item.id == id); // Remove item from UI list
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item deleted successfully!'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _setupFocusListeners() {
    _customerNameFocusNode.addListener(() {
      if (!_customerNameFocusNode.hasFocus) {
        setState(() {
          _customerNameValid = formController.customerNameController.text.trim().isNotEmpty;
        });
      }
    });

    _dateFocusNode.addListener(() {
      if (!_dateFocusNode.hasFocus) {
        setState(() {
          _dateValid = formController.dateController.text.trim().isNotEmpty;
        });
      }
    });

    _projectNameFocusNode.addListener(() {
      if (!_projectNameFocusNode.hasFocus) {
        setState(() {
          _projectNameValid = formController.projectNameController.text.trim().isNotEmpty;
        });
      }
    });

    // _mobileNumberFocusNode.addListener(() {
    //   if (!_mobileNumberFocusNode.hasFocus) {
    //     setState(() {
    //       _mobileNumberValid = formController.mobileNumberController.text.trim().length == 10;
    //     });
    //   }
    // });
  }

  Future<bool> validateFields() async {
    setState(() {
      _customerNameValid = formController.customerNameController.text.trim().isNotEmpty;
      _dateValid = formController.dateController.text.trim().isNotEmpty;
      _projectNameValid = formController.projectNameController.text.trim().isNotEmpty;
    });

    bool hasErrors = false;

    if (!_customerNameValid ||
        !_dateValid ||
        !_projectNameValid ) {
      hasErrors = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }

    if (items.isEmpty) {
      if (!hasErrors) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please add at least one item to the quotation'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
      hasErrors = true;
    }
    return !hasErrors;
  }

  @override
  void dispose() {
    formController.dispose();
    _customerNameFocusNode.dispose();
    _dateFocusNode.dispose();
    _projectNameFocusNode.dispose();
    // _mobileNumberFocusNode.dispose();
    super.dispose();
  }

  void _showCustomerSelectionSheet() {
    if (clients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No clients available."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    List<ClientDetails> filteredClients = List.from(clients);
    TextEditingController searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true, // Ensures proper keyboard handling
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FractionallySizedBox(
              heightFactor: 0.8, // Fix height to 80% of screen
              child: Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    // Header with title and close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select a Customer",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: isDarkMode ? Colors.white60 : Colors.black54),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Divider(color: isDarkMode ? Colors.white24 : Colors.black26, thickness: 1),

                    // Search Bar
                    TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          filteredClients = clients
                              .where((client) =>
                          ("${client.firstName} ${client.lastName}")
                              .toLowerCase()
                              .contains(value.toLowerCase()) ||
                              client.mobileNumber.contains(value))
                              .toList();
                        });
                      },
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white70 : Colors.grey),
                        hintText: "Search customer...",
                        hintStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54),
                        filled: true,
                        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear, color: isDarkMode ? Colors.white60 : Colors.black54),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              filteredClients = clients;
                            });
                          },
                        )
                            : null,
                      ),
                    ),

                    SizedBox(height: 10),

                    // Customer List
                    Expanded(
                      child: filteredClients.isNotEmpty
                          ? ListView.builder(
                        itemCount: filteredClients.length,
                        itemBuilder: (context, index) {
                          final client = filteredClients[index];
                          return Card(
                            color: isDarkMode ? Colors.grey[800] : Colors.white,
                            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isDarkMode ? Colors.blueGrey[700] : Colors.blue.shade100,
                                child: Icon(Icons.person, color: isDarkMode ? Colors.white : Colors.blue),
                              ),
                              title: Text(
                                "${client.firstName} ${client.lastName}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                "${client.countryCode} ${client.mobileNumber}",
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              // trailing: Icon(Icons.check_circle_outline, color: isDarkMode ? Colors.white70 : Colors.blue),
                              onTap: () {
                                setState(() {
                                  formController.customerNameController.text =
                                  "${client.firstName} ${client.lastName}";
                                  selectedCustomerMobileNumber =
                                  "${client.countryCode} ${client.mobileNumber}";
                                });
                                saveSelectedClient(
                                  "${client.firstName} ${client.lastName}",
                                  "${client.countryCode} ${client.mobileNumber}",
                                );
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      )
                          : Center(
                        child: Text(
                          "No matching customers found.",
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    return Scaffold(
      // appBar: AppBar(title: const Text("Estimation")),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Customer Name Field
              GestureDetector(
                onTap: _showCustomerSelectionSheet,
                child: AbsorbPointer(
                  child: TextField(
                    controller: formController.customerNameController,
                    decoration: InputDecoration(
                      labelText: "Customer Name",
                      prefixIcon: Icon(Icons.person, color: Colors.blue),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _customerNameValid ? Colors.blue : Colors.red,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                          color: _customerNameValid ? Colors.blue : Colors.red,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              //Date Picker Field
              TextField(
                controller: formController.dateController,
                textAlign: TextAlign.left,
                focusNode: _dateFocusNode,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_month),
                  prefixIconColor: Colors.blue,
                  labelText: "Date",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _dateValid ? Colors.blue : Colors.red,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: _dateValid ? Colors.blue : Colors.red,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // errorText: _dateValid ? null : "Date is required",
                  contentPadding: EdgeInsets.all(10),
                ),
                onTap: () async {
                  await onTapFunction(
                    context: context,
                    formController: formController,
                  );
                  if (!_dateValid &&
                      formController.dateController.text
                          .trim()
                          .isNotEmpty) {
                    setState(() {
                      _dateValid = true;
                    });
                  }
                },
              ),
              SizedBox(height: 20),

              // Project Name Field
              TextField(
                controller: formController.projectNameController,
                textAlign: TextAlign.left,
                focusNode: _projectNameFocusNode,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.shopping_bag_sharp),
                  prefixIconColor: Colors.blue,
                  labelText: "Project Name",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _projectNameValid ? Colors.blue : Colors.red,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: _projectNameValid ? Colors.blue : Colors.red,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // errorText: _projectNameValid ? null : "Project name is required",
                  contentPadding: EdgeInsets.all(10),
                ),
                onChanged: (value) {
                  if (!_projectNameValid) {
                    setState(() {
                      _projectNameValid = value
                          .trim()
                          .isNotEmpty;
                    });
                  }
                },
              ),
              SizedBox(height: 20),

              Row(
                children: [
                  // if (items.isNotEmpty)
                  Text(
                    "Items :",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(width: 55),

                  //Button to preview pdf of quotation
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.end, // Ensures fixed positions
                    children: [
                      // PDF Button (Hidden when no items)
                      items.isNotEmpty
                          ? ElevatedButton(
                        onPressed: () async {
                          if (await validateFields()) {
                            ClientDetails? client = await getClientDetailsByName(formController.customerNameController.text);

                            String rawDate = formController.dateController.text;
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

                            generatePdf(
                              customerName: formController.customerNameController.text,
                              date: formattedDate,
                              projectName: formController.projectNameController.text,
                              mobileNumber: selectedCustomerMobileNumber,
                              streetAddress: client?.streetAddress ?? "N/A",
                              city: client?.city ?? "N/A",
                              state: client?.state ?? "N/A",
                              pinCode: client?.pinCode ?? "N/A",
                              items: items,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(10),
                          backgroundColor: isDarkMode ? Colors.white12 : Colors.white,
                        ),
                        child: const Icon(Icons.picture_as_pdf, color: Colors.blue, size: 25),
                      )
                          : const SizedBox(width: 78), // Placeholder to keep layout fixed

                      SizedBox(width: 15),
                      // Save Button (Hidden when no items)
                      items.isNotEmpty
                          ? ElevatedButton(
                          onPressed: () async {
                          if (await validateFields()) {
                            double totalAmount = items.fold(0, (sum, item) => sum + item.totalCost);

                            final quotation = Quotation(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              customerName: formController.customerNameController.text,
                              date: formController.dateController.text,
                              projectName: formController.projectNameController.text,
                              mobileNumber: formController.mobileNumberController.text,
                              items: List.from(items),
                              totalAmount: totalAmount,
                            );

                            await DBHelperQuotation.instance.saveQuotation(quotation);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Quotation saved successfully!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );

                            await dbRef.deleteAllQuotationItems();

                            setState(() {
                              formController.customerNameController.clear();
                              formController.dateController.clear();
                              formController.projectNameController.clear();
                              formController.mobileNumberController.clear();
                              selectedCustomerMobileNumber = "";
                              items.clear();
                            });

                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.remove('selected_customer');
                            await prefs.remove('selected_mobile');

                            getQuotationItems();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(10),
                          backgroundColor: isDarkMode ? Colors.white12 : Colors.white,
                        ),
                        child: const Icon(Icons.save, color: Colors.blue, size: 25),
                      )
                          : const SizedBox(width: 50), // Placeholder to keep layout fixed

                      // Add Item Button (Always Visible & Fixed at Rightmost)
                      SizedBox(width: 15),
                      ElevatedButton(
                        onPressed: () async {
                          final result = await showBottomPopup(context);
                          if (result != null) {
                            await addQuotationItem(result);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(10),
                          backgroundColor: isDarkMode ? Colors.white12 : Colors.white,
                        ),
                        child: const Icon(Icons.add, color: Colors.blue, size: 25),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5),
              Expanded(
                child:
                items.isNotEmpty ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ExpansionTile(
                        title: Text(
                          item.itemName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          item.unit == "N/A"
                              ? "Area: N/A"
                              : 'Area: ${item.squareFeet.toStringAsFixed(2)} sq ft'
                              '${item.unit == "R. Foot" ? "" : " (${item.length} × ${item.width}${item.height != null ? ' × ${item.height}' : ''} ${item.unit})"}',
                          style: TextStyle(fontSize: 12),
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: 16,
                              right: 16,
                              // bottom: 2,
                              // vertical: 1,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // SizedBox(height: 0), // Reduced spacing
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Quantity: ${item.quantity}'),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        // Edit Button
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: isDarkMode ? Colors.white : Colors.black,
                                            size: 20,
                                          ),
                                          onPressed: () async {
                                            final updatedItem =
                                            await showBottomPopup(
                                              context,
                                              existingItem: item,
                                            );
                                            if (updatedItem != null) {
                                              await updateQuotationItem(
                                                item,
                                                updatedItem,
                                              );
                                            }
                                          },
                                          padding: EdgeInsets.all(4),
                                          constraints: BoxConstraints(),
                                        ),
                                        SizedBox(width: 4),
                                        // Delete Button
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () async {
                                            await deleteQuotationItem(
                                              item.id,
                                            );
                                          },
                                          padding: EdgeInsets.all(4),
                                          // constraints: BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Rate info
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Rate: ${item.rate.toStringAsFixed(2)}',
                                    ),
                                    Text(
                                      'Total: ${NumberFormat("#,##0.00").format(item.totalCost)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8), // Reduced bottom spacing
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
                    : const SizedBox(height: 30,)
                  // child: Center(child: Text("No items added yet.")))
              ),
            ],
          ),
        ),
      ),
    );
  }
}
