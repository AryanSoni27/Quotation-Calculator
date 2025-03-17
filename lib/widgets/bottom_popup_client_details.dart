import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quotation/models/client_details.dart';
import '../main.dart';

Future<ClientDetails?> showClientForm(BuildContext context, {ClientDetails? existingItem}) async {
  ClientDetailsFormController formController = ClientDetailsFormController();

  bool isFirstNameValid = true;
  bool isLastNameValid = true;
  bool isMobileValid = true;
  bool isAddressValid = true;
  bool isCityValid = true;
  bool isPinCodeValid = true;
  bool isStateValid = true;

  FocusNode firstNameFocusNode = FocusNode();
  FocusNode lastNameFocusNode = FocusNode();
  FocusNode mobileFocusNode = FocusNode();
  FocusNode addressFocusNode = FocusNode();
  FocusNode cityFocusNode = FocusNode();
  FocusNode pinCodeFocusNode = FocusNode();
  FocusNode stateFocusNode = FocusNode();

  void setupFocusListeners() {
    firstNameFocusNode.addListener(() {
      if (!firstNameFocusNode.hasFocus) {
        isFirstNameValid = formController.firstNameController.text.trim().isNotEmpty;
      }
    });

    lastNameFocusNode.addListener(() {
      if (!lastNameFocusNode.hasFocus) {
        isLastNameValid = formController.lastNameController.text.trim().isNotEmpty;
      }
    });

    mobileFocusNode.addListener(() {
      if (!mobileFocusNode.hasFocus) {
        isMobileValid = formController.mobileNumberController.text.length == 10;
      }
    });

    addressFocusNode.addListener(() {
      if (!addressFocusNode.hasFocus) {
        isAddressValid = formController.streetAddressController.text.trim().isNotEmpty;
      }
    });

    cityFocusNode.addListener(() {
      if (!cityFocusNode.hasFocus) {
        isCityValid = formController.cityController.text.trim().isNotEmpty;
      }
    });

    pinCodeFocusNode.addListener(() {
      if (!pinCodeFocusNode.hasFocus) {
        isPinCodeValid = formController.pinCodeController.text.length == 6;
      }
    });

    stateFocusNode.addListener(() {
      if (!stateFocusNode.hasFocus) {
        isStateValid = formController.stateController.text.trim().isNotEmpty;
      }
    });
  }

  setupFocusListeners();

  // @override
  // void initState() {
  //   setupFocusListeners();
  // }

  // Populate controllers with existing data if available
  if (existingItem != null) {
    formController.firstNameController.text = existingItem.firstName;
    formController.lastNameController.text = existingItem.lastName;
    formController.mobileNumberController.text = existingItem.mobileNumber;
    formController.streetAddressController.text = existingItem.streetAddress;
    formController.cityController.text = existingItem.city;
    formController.pinCodeController.text = existingItem.pinCode;
    formController.stateController.text = existingItem.state;
  }

  return showModalBottomSheet<ClientDetails>(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final themeProvider = Provider.of<ThemeProvider>(context);
      final isDarkMode = themeProvider.isDarkMode;

      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Wrap(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Center(
                      child: Text(
                        existingItem != null ? "Edit Client Details" : "Enter Client Details",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),

                    // First Name Field
                    TextField(
                      textAlign: TextAlign.left,
                      controller: formController.firstNameController,
                      focusNode: firstNameFocusNode,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        prefixIconColor: Colors.blue,
                        labelText: "First Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isFirstNameValid ? Colors.blue : Colors.red,
                            width: 1,
                          ),
                        ),
                        focusedBorder : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isFirstNameValid ? Colors.blue : Colors.red,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Last Name Field
                    TextField(
                      textAlign: TextAlign.left,
                      controller: formController.lastNameController,
                      focusNode: lastNameFocusNode,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        prefixIconColor: Colors.blue,
                        labelText: "Last Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isLastNameValid ? Colors.blue : Colors.red,
                            width: 1,
                          ),
                        ),
                        focusedBorder : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isLastNameValid ? Colors.blue : Colors.red,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Mobile Number Field
                    TextField(
                      textAlign: TextAlign.left,
                      controller: formController.mobileNumberController,
                      keyboardType: TextInputType.phone,
                      focusNode: mobileFocusNode,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone, color: Colors.blue),
                        labelText: "Mobile Number",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isMobileValid ? Colors.blue : Colors.red,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isMobileValid ? Colors.blue : Colors.red,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(10),
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        setState(() {
                          isMobileValid = value.length == 10;
                        });
                      },
                      onTap: () {
                        setState(() {
                          var isMobileFocused = true;
                        });
                      },
                      onEditingComplete: () {
                        setState(() {
                          isMobileValid = formController.mobileNumberController.text.length == 10;
                        });
                        mobileFocusNode.unfocus();
                      },
                    ),
                    SizedBox(height: 10),

                    Text("Address:-"),
                    SizedBox(height: 10),

                    //Address Field
                    TextField(
                      textAlign: TextAlign.left,
                      controller: formController.streetAddressController,
                      keyboardType: TextInputType.streetAddress,
                      focusNode: addressFocusNode,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.home_filled),
                        prefixIconColor: Colors.blue,
                        labelText: "Address",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isAddressValid ? Colors.blue : Colors.red,
                            width: 1,
                          ),
                        ),
                        focusedBorder : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isAddressValid ? Colors.blue : Colors.red,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                    SizedBox(height: 10),

                    // City Field
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            textAlign: TextAlign.left,
                            controller: formController.cityController,
                            keyboardType: TextInputType.streetAddress,
                            focusNode: cityFocusNode,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.location_city),
                              prefixIconColor: Colors.blue,
                              labelText: "City",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: isCityValid ? Colors.blue : Colors.red,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: isCityValid ? Colors.blue : Colors.red,
                                  width: 2,
                                ),
                              ),
                              contentPadding: EdgeInsets.all(10),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            textAlign: TextAlign.left,
                            controller: formController.pinCodeController,
                            keyboardType: TextInputType.number,
                            focusNode: pinCodeFocusNode,
                            inputFormatters: [LengthLimitingTextInputFormatter(6), FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.pin),
                              prefixIconColor: Colors.blue,
                              labelText: "Pin Code",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: isPinCodeValid ? Colors.blue : Colors.red,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: isPinCodeValid ? Colors.blue : Colors.red,
                                  width: 2,
                                ),
                              ),
                              contentPadding: EdgeInsets.all(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    // State Field
                    TextField(
                      textAlign: TextAlign.left,
                      controller: formController.stateController,
                      keyboardType: TextInputType.streetAddress,
                      focusNode: stateFocusNode,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.map),
                        prefixIconColor: Colors.blue,
                        labelText: "State",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isStateValid ? Colors.blue : Colors.red,
                            width: 1,
                          ),
                        ),
                        focusedBorder : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isStateValid ? Colors.blue : Colors.red,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Add Client Button
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? Colors.white12 : Colors.white,
                          elevation: 10,
                        ),
                          onPressed: () {
                            if (formController.firstNameController.text.isEmpty ||
                            formController.lastNameController.text.isEmpty ||
                            formController.mobileNumberController.text.isEmpty ||
                            formController.mobileNumberController.text.length != 10 ||
                            formController.streetAddressController.text.isEmpty ||
                            formController.cityController.text.isEmpty ||
                            formController.pinCodeController.text.isEmpty ||
                            formController.pinCodeController.text.length != 6 ||
                            formController.stateController.text.isEmpty) {

                            ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Please fill all required fields correctly."),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                        final client = ClientDetails(
                          firstName: formController.firstNameController.text,
                          lastName: formController.lastNameController.text,
                          mobileNumber: formController.mobileNumberController.text,
                          streetAddress: formController.streetAddressController.text,
                          city: formController.cityController.text,
                          state: formController.stateController.text,
                          pinCode: formController.pinCodeController.text,
                        );
                        Navigator.of(context).pop(client);
                        },

                        child: Text(
                          existingItem != null ? "Update Client" : "Add Client",
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
