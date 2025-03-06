import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/quotation_item.dart';
import '../util/date_picker.dart';
import '../services/pdf_generator.dart';
import '../widgets/bottom_popup_quotation_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FormController formController = FormController();
  List<QuotationItem> items = [];

  bool _customerNameValid = true;
  bool _dateValid = true;
  bool _projectNameValid = true;
  bool _mobileNumberValid = true;

  final FocusNode _customerNameFocusNode = FocusNode();
  final FocusNode _dateFocusNode = FocusNode();
  final FocusNode _projectNameFocusNode = FocusNode();
  final FocusNode _mobileNumberFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _setupFocusListeners();
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Customer Name Field
            TextField(
              controller: formController.customerNameController,
              textAlign: TextAlign.left,
              focusNode: _customerNameFocusNode,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                prefixIconColor: Colors.blue,
                labelText: "Customer Name",
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
                errorText:
                _customerNameValid ? null : "Customer name is required",
                contentPadding: EdgeInsets.all(10),
              ),
              onChanged: (value) {
                if (!_customerNameValid) {
                  setState(() {
                    _customerNameValid = value.trim().isNotEmpty;
                  });
                }
              },
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
                errorText: _dateValid ? null : "Date is required",
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
                errorText:
                _projectNameValid ? null : "Project name is required",
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
                errorText:
                _mobileNumberValid ? null : "Mobile number is required",
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

            if (items.isNotEmpty) ...[
              SizedBox(height: 20),
              Text(
                "Added Items:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(item.itemName),
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
                          Text('Rate: ${item.rate.toStringAsFixed(2)}'),
                          Text('Total: ${item.totalCost.toStringAsFixed(2)}'),
                        ],
                      ),
                      //Added delete and edit button for each item
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Edit Button
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.black),
                            onPressed: () async {
                              final updatedItem = await showBottomPopup(
                                context,
                                existingItem: items[index],
                              );
                              if (updatedItem != null) {
                                setState(() {
                                  items[index] = updatedItem;
                                });
                              }
                            },
                          ),

                          //Delete Button
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                items.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],

            SizedBox(height: 40),

            //Button to add items
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: Size(40, 40)),
                onPressed: () async {
                  //Wait for and handle the result from bottom popup
                  final result = await showBottomPopup(context);
                  if (result != null) {
                    setState(() {
                      items.add(result);
                    });
                  }
                },
                child: Text("Add Item"),
              ),
            ),
            SizedBox(height: 30),

            //Submit Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: Size(200, 40)),
                onPressed: () async {
                  // Validate all fields before generating PDF
                  if (await validateFields()) {
                    generatePdf(
                      customerName:
                      formController.customerNameController.text,
                      date: formController.dateController.text,
                      projectName: formController.projectNameController.text,
                      mobileNumber:
                      formController.mobileNumberController.text,
                      items: items,
                    );
                  }
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
