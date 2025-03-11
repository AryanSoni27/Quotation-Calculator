import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quotation/models/client_details.dart';
import 'package:quotation/models/quotation_item.dart';
import 'package:quotation/widgets/bottom_popup_client_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/client_details.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});


  @override
  ClientScreenState createState() => ClientScreenState();
}

class ClientScreenState extends State<ClientScreen> {
  final ClientDetailsFormController formController = ClientDetailsFormController();
  List<ClientDetails> clients = [];

  @override
  void initState() {
    super.initState();
    loadClientDetails();
  }

  Future<void> loadClientDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? clientJsonList = prefs.getStringList('client_list');

    if (clientJsonList != null) {
      setState(() {
        clients = clientJsonList.map((jsonString) => ClientDetails.fromJson(jsonDecode(jsonString))).toList();
      });
    }
  }

  Future<void> saveClientList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> clientJsonList = clients.map((client) => jsonEncode(client.toJson())).toList();
    await prefs.setStringList('client_list', clientJsonList);
  }

  void setupTextFieldListeners() {
    formController.firstNameController.addListener(saveClientList);
    formController.lastNameController.addListener(saveClientList);
    formController.mobileNumberController.addListener(saveClientList);
    formController.streetAddressController.addListener(saveClientList);
    formController.cityController.addListener(saveClientList);
    formController.stateController.addListener(saveClientList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //     title: const Text("Clients")
      // ),
      body:
      clients.isEmpty
          ? Center(child: Text('No clients added yet'))
          : ListView.builder(
        padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
        itemCount: clients.length,
        itemBuilder: (BuildContext context, int index) {
          final client = clients[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              // Padding inside the card
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                // Avatar background color
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
              title: Text(
                "${client.firstName} ${client.lastName}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.green),
                      SizedBox(width: 5),
                      Text(
                        client.mobileNumber,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.home, size: 16, color: Colors.blue),
                      SizedBox(width: 5),
                      Expanded(
                        // Prevent overflow
                        child: Text('${client.streetAddress}, ${client.city}, ${client.state}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1, // Limit to one line
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit Button
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.black),
                    onPressed: () async {
                      // Pass the existing client data to showClientForm
                      final updatedClient = await showClientForm(
                        context,
                        existingItem: clients[index],
                      );
                      if (updatedClient != null) {
                        setState(() {
                          clients[index] = updatedClient;
                          saveClientList(); // Save after updating
                        });
                      }
                    },
                  ),

                  //Delete Button
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        clients.removeAt(index);
                        saveClientList(); // Save updated list
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // FloatingActionButton at the bottom right
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed: () async {
          final result = await showClientForm(context);
          if (result != null) {
            setState(() {
              clients.add(result);
              saveClientList(); // Save updated list
            });
          }
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}