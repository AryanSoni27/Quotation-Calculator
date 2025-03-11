import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quotation/models/client_details.dart';
import 'package:quotation/models/client_details.dart';

Future<ClientDetails?> showClientForm(BuildContext context, {ClientDetails? existingItem}) async {
  // Create controllers
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController streetAddressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();

  // Populate controllers with existing data if available
  if (existingItem != null) {
    firstNameController.text = existingItem.firstName;
    lastNameController.text = existingItem.lastName;
    mobileNumberController.text = existingItem.mobileNumber;
    streetAddressController.text = existingItem.streetAddress;
    cityController.text = existingItem.city;
    stateController.text = existingItem.state;
  }

  return showModalBottomSheet<ClientDetails>(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
                padding:EdgeInsets.only(
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
                            //Title of Client Popup
                            Center(
                              child: Text(
                                existingItem != null ? "Edit Client Details" : "Enter Client Details",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 10),

                            //First Name Field
                            TextField(
                              textAlign: TextAlign.left,
                              controller: firstNameController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person),
                                prefixIconColor: Colors.blue,
                                labelText: "First Name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: EdgeInsets.all(10),
                              ),
                            ),
                            SizedBox(height: 10),

                            //Last Name Field
                            TextField(
                              textAlign: TextAlign.left,
                              controller: lastNameController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person),
                                prefixIconColor: Colors.blue,
                                labelText: "Last Name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: EdgeInsets.all(10),
                              ),
                            ),
                            SizedBox(height: 10),

                            //Mobile Number Field
                            TextField(
                              textAlign: TextAlign.left,
                              controller: mobileNumberController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.phone),
                                prefixIconColor: Colors.blue,
                                labelText: "Mobile Number",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: EdgeInsets.all(10),
                              ),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            SizedBox(height: 10),
                            Text("Address:-"),
                            SizedBox(height: 10),
                            //Street Address Field
                            TextField(
                              textAlign: TextAlign.left,
                              controller: streetAddressController,
                              keyboardType: TextInputType.streetAddress,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.home_filled),
                                prefixIconColor: Colors.blue,
                                labelText: "Street Address",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: EdgeInsets.all(10),
                              ),
                            ),
                            SizedBox(height: 10),

                            //City Field
                            TextField(
                              textAlign: TextAlign.left,
                              controller: cityController,
                              keyboardType: TextInputType.streetAddress,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.home_filled),
                                prefixIconColor: Colors.blue,
                                labelText: "City",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: EdgeInsets.all(10),
                              ),
                            ),
                            SizedBox(height: 10),

                            //State Field
                            TextField(
                              textAlign: TextAlign.left,
                              controller: stateController,
                              keyboardType: TextInputType.streetAddress,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.home_filled),
                                prefixIconColor: Colors.blue,
                                labelText: "State",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: EdgeInsets.all(10),
                              ),
                            ),
                            SizedBox(height: 20),

                            //Add Client Button
                            Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    final client = ClientDetails(
                                      firstName: firstNameController.text,
                                      lastName: lastNameController.text,
                                      mobileNumber: mobileNumberController.text,
                                      streetAddress: streetAddressController.text,
                                      city: cityController.text,
                                      state: stateController.text,
                                    );
                                    Navigator.of(context).pop(client);
                                  },
                                  child: Text(existingItem != null ? "Update Client" : "Add Client"),
                                )
                            )
                          ]
                      )
                    ]
                )
            );
          }
      );
    },
  );
}