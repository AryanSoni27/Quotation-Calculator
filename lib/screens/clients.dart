import 'package:flutter/material.dart';
import 'package:quotation/models/client_details.dart';
import 'package:quotation/widgets/bottom_popup_client_details.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  ClientScreenState createState() => ClientScreenState();
}

class ClientScreenState extends State<ClientScreen> {
  List<ClientDetails> clients = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //     title: const Text("Clients")
      // ),
      body: clients.isEmpty
          ? Center(child: Text('No clients added yet'))
          : ListView.builder(
        // Removed shrinkWrap and NeverScrollableScrollPhysics to enable scrolling
        itemCount: clients.length,
        itemBuilder: (BuildContext context, int index) {
          final client = clients[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: ListTile(
              title: Text(client.firstName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Last Name: ${client.lastName}'),
                  Text('Mobile Number: ${client.mobileNumber}'),
                  Text('Address: ${client.address}'),
                ],
              ),
            ),
          );
        },
      ),
      // FloatingActionButton at the bottom right
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //Wait for and handle the result from bottom popup
          final result = await showClientForm(context);
          if (result != null) {
            setState(() {
              clients.add(result);
            });
          }
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}