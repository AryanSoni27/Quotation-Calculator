import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quotation/main.dart';
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
  List<ClientDetails> filteredClients = [];
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    loadClientDetails();
    searchController.addListener(_filterClients);
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadClientDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? clientJsonList = prefs.getStringList('client_list');
    if (clientJsonList != null) {
      setState(() {
        clients = clientJsonList.map((jsonString) => ClientDetails.fromJson(jsonDecode(jsonString))).toList();
        filteredClients = clients;
      });
    }
  }

  void _filterClients() {
    setState(() {
      filteredClients = clients.where((client) {
        final name = "${client.firstName} ${client.lastName}".toLowerCase();
        return name.contains(searchController.text.toLowerCase());
      }).toList();
    });
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
      appBar: AppBar(
        title: const Text("Clients"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (_isSearchVisible) {
                  // Delay to ensure the search bar is rendered before requesting focus
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).requestFocus(searchFocusNode);
                  });
                } else {
                  searchController.clear();
                  filteredClients = clients;
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearchVisible)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black26
                          : Colors.grey.shade300,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  focusNode: searchFocusNode,
                  controller: searchController,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: "Search clients by name...",
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDarkMode ? Colors.white60 : Colors.black54,
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: isDarkMode ? Colors.white60 : Colors.black54,
                      ),
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          filteredClients = clients;
                        });
                      },
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14
                    ),
                  ),
                  cursorColor: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          Expanded(
            child: filteredClients.isEmpty
                ? Center(
              child: Text(
                'No clients found',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              itemCount: filteredClients.length,
              itemBuilder: (BuildContext context, int index) {
                final client = filteredClients[index];
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
                            Expanded(
                              child: Text(
                                "${client.countryCode} ${client.mobileNumber}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                                overflow: TextOverflow.ellipsis,
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
          ),
        ],
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