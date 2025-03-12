import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FormController formController = FormController();
  List<QuotationItem> items = [];
  List<Map<String, dynamic>> allQuotationItems = [];
  DBHelper dbRef = DBHelper.instance;

  List<String> clientNames = [];

  bool _customerNameValid = true;
  bool _dateValid = true;
  bool _projectNameValid = true;
  bool _mobileNumberValid = true;
  bool _showDropdown = false;

  String selectedCustomer = "";

  final FocusNode _customerNameFocusNode = FocusNode();
  final FocusNode _dateFocusNode = FocusNode();
  final FocusNode _projectNameFocusNode = FocusNode();
  final FocusNode _mobileNumberFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    getQuotationItems();
    loadCustomerDetails();
    setupTextFieldListeners();
    _setupFocusListeners();
    loadClients();
  }

  Future<void> loadClients() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? clientJsonList = prefs.getStringList('client_list');

    if (clientJsonList != null) {
      setState(() {
        clientNames =
            clientJsonList
                .map(
                  (jsonString) =>
                      ClientDetails.fromJson(jsonDecode(jsonString)).firstName,
                )
                .toList();
      });
    }
  }

  Future<void> saveSelectedCustomer(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_customer', name);
  }

  void clearFormFields() {
    setState(() {
      formController.customerNameController.clear();
      _customerNameValid = false;
    });
  }

  Future<void> loadCustomerDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      formController.customerNameController.text =
          prefs.getString('customer_name') ?? '';
      formController.mobileNumberController.text =
          prefs.getString('mobile_number') ?? '';
      formController.projectNameController.text =
          prefs.getString('project_name') ?? '';
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
            length: (item['length'] as num).toDouble(),
            width: (item['width'] as num).toDouble(),
            height:
                item['height'] != null
                    ? (item['height'] as num).toDouble()
                    : null,
            squareFeet: (item['square_feet'] as num).toDouble(),
            quantity: item['quantity'] as int,
            rate: (item['rate'] as num).toDouble(),
            totalCost: (item['total_cost'] as num).toDouble(),
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
      DBHelper.COLUMN_SHAPE: item.shape,
      DBHelper.COLUMN_LENGTH: item.length,
      DBHelper.COLUMN_WIDTH: item.width,
      if (item.height != null) DBHelper.COLUMN_HEIGHT: item.height,
      DBHelper.COLUMN_SQUARE_FEET: item.squareFeet,
      DBHelper.COLUMN_QUANTITY: item.quantity,
      DBHelper.COLUMN_RATE: item.rate,
      DBHelper.COLUMN_TOTAL_COST: item.totalCost,
    };

    await dbRef.insertQuotationItem(row); // Insert into database

    getQuotationItems(); // Reload items from database to ensure persistence
  }

  // Update a quotation item in database
  Future<void> updateQuotationItem(
    QuotationItem oldItem,
    QuotationItem newItem,
  ) async {
    Map<String, dynamic> updatedValues = {
      DBHelper.COLUMN_ITEM_NAME: newItem.itemName,
      DBHelper.COLUMN_UNIT: newItem.unit,
      DBHelper.COLUMN_SHAPE: newItem.shape,
      DBHelper.COLUMN_LENGTH: newItem.length,
      DBHelper.COLUMN_WIDTH: newItem.width,
      if (newItem.height != null) DBHelper.COLUMN_HEIGHT: newItem.height,
      DBHelper.COLUMN_SQUARE_FEET: newItem.squareFeet,
      DBHelper.COLUMN_QUANTITY: newItem.quantity,
      DBHelper.COLUMN_RATE: newItem.rate,
      DBHelper.COLUMN_TOTAL_COST: newItem.totalCost,
    };

    await dbRef.updateQuotationItem(
      oldItem.itemName,
      oldItem.unit,
      oldItem.shape,
      oldItem.length,
      oldItem.width,
      oldItem.height,
      updatedValues,
    );

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
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _setupFocusListeners() {
    _customerNameFocusNode.addListener(() {
      if (!_customerNameFocusNode.hasFocus) {
        setState(() {
          _customerNameValid =
              formController.customerNameController.text.trim().isNotEmpty;
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
          _projectNameValid =
              formController.projectNameController.text.trim().isNotEmpty;
        });
      }
    });

    _mobileNumberFocusNode.addListener(() {
      if (!_mobileNumberFocusNode.hasFocus) {
        setState(() {
          _mobileNumberValid =
              formController.mobileNumberController.text.trim().length == 10;
        });
      }
    });
  }

  Future<bool> validateFields() async {
    setState(() {
      _customerNameValid =
          formController.customerNameController.text.trim().isNotEmpty;
      _dateValid = formController.dateController.text.trim().isNotEmpty;
      _projectNameValid =
          formController.projectNameController.text.trim().isNotEmpty;
      _mobileNumberValid =
          formController.mobileNumberController.text.trim().length == 10;
    });

    bool hasErrors = false;

    if (!_customerNameValid ||
        !_dateValid ||
        !_projectNameValid ||
        !_mobileNumberValid) {
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
    _mobileNumberFocusNode.dispose();
    super.dispose();
  }

  void _showCustomerSelectionSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: clientNames.map((name) => ListTile(
              title: Text(name),
              onTap: () {
                setState(() {
                  formController.customerNameController.text = name;
                  _customerNameValid = true;
                });
                Navigator.pop(context);
                saveSelectedCustomer(name);
              },
            )).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    return Scaffold(
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
                      formController.dateController.text.trim().isNotEmpty) {
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
                      _projectNameValid = value.trim().isNotEmpty;
                    });
                  }
                },
              ),
              SizedBox(height: 20),

              // Mobile Number Field
              TextField(
                controller: formController.mobileNumberController,
                textAlign: TextAlign.left,
                focusNode: _mobileNumberFocusNode,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone),
                  prefixIconColor: Colors.blue,
                  labelText: "Mobile Number",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _mobileNumberValid ? Colors.blue : Colors.red,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: _mobileNumberValid ? Colors.blue : Colors.red,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // errorText: _mobileNumberValid ? null : "Mobile number is required",
                  contentPadding: EdgeInsets.all(10),
                ),
                onChanged: (value) {
                  setState(() {
                    _mobileNumberValid =
                        value.trim().length ==
                        10; // Valid only if exactly 10 digits
                  });
                },
              ),
              SizedBox(height: 10),
              Row(
                  children: [
                    if (items.isNotEmpty)
                      Text("Added Items:-", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87)),
                    SizedBox(width: 34),
                    if (items.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Preview PDF Button
                            Column(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    if (await validateFields()) {
                                      generatePdf(
                                        customerName:
                                        formController
                                            .customerNameController
                                            .text,
                                        date: formController.dateController.text,
                                        projectName:
                                        formController.projectNameController.text,
                                        mobileNumber:
                                        formController
                                            .mobileNumberController
                                            .text,
                                        items: items,
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade300,
                                          spreadRadius: 0.5,
                                          blurRadius: 5,
                                          offset: Offset(2, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.picture_as_pdf,
                                        size: 36,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                                // const SizedBox(height: 8),
                                // Text(
                                //   "Preview",
                                //   style: TextStyle(
                                //     fontSize: 14,
                                //     fontWeight: FontWeight.w500,
                                //     color: isDarkMode ? Colors.white : Colors.black87,
                                //   ),
                                // ),
                              ],
                            ),
                            SizedBox(width: 30),
                            // Save Quotation Button
                            Column(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    // Validate all fields before generating PDF
                                    if (await validateFields()) {
                                      // Calculate total amount
                                      double totalAmount = items.fold(
                                        0,
                                            (sum, item) => sum + item.totalCost,
                                      );

                                      // Create quotation object
                                      final quotation = Quotation(
                                        id:
                                        DateTime.now().millisecondsSinceEpoch
                                            .toString(),
                                        customerName:
                                        formController
                                            .customerNameController
                                            .text,
                                        date: formController.dateController.text,
                                        projectName:
                                        formController.projectNameController.text,
                                        mobileNumber:
                                        formController
                                            .mobileNumberController
                                            .text,
                                        items: List.from(items),
                                        totalAmount: totalAmount,
                                      );

                                      // Save to database
                                      await DBHelperQuotation.instance.saveQuotation(
                                        quotation,
                                      );

                                      // Show success message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Quotation saved successfully!',
                                          ),
                                          backgroundColor: Colors.green,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );

                                      // First clear database items
                                      await dbRef.deleteAllQuotationItems();

                                      // Then clear the UI state
                                      setState(() {
                                        formController.customerNameController.clear();
                                        formController.dateController.clear();
                                        formController.projectNameController.clear();
                                        formController.mobileNumberController.clear();
                                        items.clear(); // Clear the items list
                                      });

                                      // Force refresh items from database to ensure UI is in sync
                                      getQuotationItems();
                                    }
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade300,
                                          spreadRadius: 0.5,
                                          blurRadius: 5,
                                          offset: Offset(2, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.save,
                                        size: 36,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                                // const SizedBox(height: 8),
                                // Text(
                                //   "Save",
                                //   style: TextStyle(
                                //     fontSize: 14,
                                //     fontWeight: FontWeight.w500,
                                //     color: isDarkMode ? Colors.white : Colors.black87,
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ]
                ),
              SizedBox(height: 10),
              Expanded(
                child:
                    items.isNotEmpty
                        ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(
                                  item.itemName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item.length} × ${item.width}${item.height != null ? ' × ${item.height}' : ''} ${item.unit}',
                                    ),
                                    Text(
                                      'Area: ${item.squareFeet.toStringAsFixed(2)} sq ft',
                                    ),
                                    Text('Quantity: ${item.quantity}'),
                                    Text(
                                      'Rate: ${item.rate.toStringAsFixed(2)}',
                                    ),
                                    Text(
                                      'Total: ${item.totalCost.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                //Added delete and edit button for each item
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Edit Button
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color:
                                            isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
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
                                          ); // Pass old and new item
                                        }
                                      },
                                    ),

                                    //Delete Button
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        await deleteQuotationItem(item.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                        : const SizedBox(height: 30),
              ),

              // Preview PDF Button

            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Action to add a new item
          final result = await showBottomPopup(context);
          if (result != null) {
            await addQuotationItem(result); // Save to database
          }
        },
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        icon: Icon(Icons.add, color: Colors.blue),
        label: Text(
          "Item",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Bottom right position
    );
  }
}
