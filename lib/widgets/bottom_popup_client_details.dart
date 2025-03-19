import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:quotation/models/client_details.dart';
import '../main.dart';
import '../util/date_picker.dart';
import '../data/country_codes.dart';

Future<ClientDetails?> showClientForm(BuildContext context, {ClientDetails? existingItem}) async {
  ClientDetailsFormController formController = ClientDetailsFormController();

  bool isFirstNameValid = true;
  bool isLastNameValid = true;
  bool isDateValid = true;
  bool isMobileValid = true;
  bool isAddressValid = true;
  bool isCityValid = true;
  bool isPinCodeValid = true;
  bool isStateValid = true;

  FocusNode firstNameFocusNode = FocusNode();
  FocusNode lastNameFocusNode = FocusNode();
  FocusNode dateFocusNode = FocusNode();
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

    dateFocusNode.addListener(() {
      if (!dateFocusNode.hasFocus) {
        isDateValid = formController.dateController.text.trim().isNotEmpty;
      }
    });

    mobileFocusNode.addListener(() {
      if (!mobileFocusNode.hasFocus) {
        isMobileValid = formController.mobileNumberController.text.trim().isNotEmpty;
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

  // Default to India
  // Default to India
  // Default to India
  // Default to India
  String initialCountryCode = 'IN';

  if (existingItem != null) {
    formController.firstNameController.text = existingItem.firstName;
    formController.lastNameController.text = existingItem.lastName;
    formController.dateController.text = existingItem.date;
    formController.countryCodeController = existingItem.countryCode;
    formController.mobileNumberController.text = existingItem.mobileNumber;
    formController.streetAddressController.text = existingItem.streetAddress;
    formController.cityController.text = existingItem.city;
    formController.pinCodeController.text = existingItem.pinCode;
    formController.stateController.text = existingItem.state;

    // Ensure the country code exists in the map
    String countryCodeKey = existingItem.countryCode;
    if (countryCodeToIso.containsKey(countryCodeKey)) {
      List<String> isoList = countryCodeToIso[countryCodeKey]!;

      // Check if the previous selection is in the list
      if (isoList.contains(existingItem.countryCode.replaceAll('+', ''))) {
        initialCountryCode = existingItem.countryCode.replaceAll('+', '');
      } else {
        initialCountryCode = isoList.first;
      }
    }
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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
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
                        ),
                        SizedBox(width: 10),
                        //Last Name Field
                        Expanded(
                          child: TextField(
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
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    TextField(
                      controller: formController.dateController,
                      textAlign: TextAlign.left,
                      focusNode: dateFocusNode,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.calendar_month),
                        prefixIconColor: Colors.blue,
                        labelText: "Birth Date",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDateValid ? Colors.blue : Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: isDateValid ? Colors.blue : Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.all(10),
                      ),
                      onTap: () async {
                        await datePickerFunction(
                          context: context,
                          formController: formController,
                        );
                        if (!isDateValid &&
                            formController.dateController.text
                                .trim()
                                .isNotEmpty) {
                          setState(() {
                            isDateValid = true;
                          });
                        }
                      },
                    ),

                    SizedBox(height: 10),
                    // Mobile Number Field
                    IntlPhoneField(
                      textAlign: TextAlign.left,
                      controller: formController.mobileNumberController,
                      keyboardType: TextInputType.phone,
                      initialCountryCode: initialCountryCode,
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
                            color: Colors.blue,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(10),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      disableLengthCheck: false,
                      onCountryChanged: (country) {
                        // Update the country code when changed
                        formController.countryCodeController = '+${country.dialCode}';
                      },
                      initialValue: existingItem?.mobileNumber, // Preserve the number
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
                              formController.dateController.text.isEmpty ||
                              formController.mobileNumberController.text.isEmpty ||
                              formController.streetAddressController.text.isEmpty ||
                              formController.cityController.text.isEmpty ||
                              formController.pinCodeController.text.isEmpty ||
                              formController.pinCodeController.text.length != 6 ||
                              formController.stateController.text.isEmpty) {

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Please fill all required fields correctly."),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 1),
                              ),
                            );
                            return;
                          }

                          final client = ClientDetails(
                            firstName: formController.firstNameController.text,
                            lastName: formController.lastNameController.text,
                            date: formController.dateController.text,
                            mobileNumber: formController.mobileNumberController.text,
                            countryCode: formController.countryCodeController,
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