import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quotation/main.dart'; // Import ThemeProvider
import 'package:quotation/models/client_details.dart';
import 'package:quotation/widgets/bottom_popup_client_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(title: const Text("Clients")),
      body: clients.isEmpty
          ? Center(
        child: Text(
          'No clients added yet',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        itemCount: clients.length,
        itemBuilder: (BuildContext context, int index) {
          final client = clients[index];
          return Card(
            elevation: 4,
            color: isDarkMode ? Colors.white10 : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: isDarkMode ? Colors.grey : Colors.blueAccent,
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
              title: Text(
                "${client.firstName} ${client.lastName}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.green),
                      const SizedBox(width: 5),
                      Text(
                        client.mobileNumber,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.home, size: 16, color: Colors.blue),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${client.streetAddress}, ${client.city}, ${client.state}, ${client.pinCode}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: isDarkMode ? Colors.white : Colors.black),
                    onPressed: () async {
                      final updatedClient = await showClientForm(
                        context,
                        existingItem: clients[index],
                      );
                      if (updatedClient != null) {
                        setState(() {
                          clients[index] = updatedClient;
                          saveClientList();
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        clients.removeAt(index);
                        saveClientList();
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        backgroundColor: Colors.white,
        onPressed: () async {
          final result = await showClientForm(context);
          if (result != null) {
            setState(() {
              clients.add(result);
              saveClientList();
            });
          }
        },
        child: const Icon(Icons.add, color: Colors.blue),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
