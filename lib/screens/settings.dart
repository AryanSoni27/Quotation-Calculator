import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quotation/main.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Settings"),
      // ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text("Dark Mode"),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (bool value) {
                themeProvider.toggleDarkMode();
              },
            ),
          ),
          // ListTile(
          //   leading: const Icon(Icons.notifications),
          //   title: const Text("Enable Notifications"),
          //   trailing: Switch(
          //     value: true,
          //     onChanged: (bool value) {
          //       // Handle notification toggle
          //     },
          //   ),
          // ),
          // const Divider(),
          // ListTile(
          //   leading: const Icon(Icons.account_circle),
          //   title: const Text("Account Settings"),
          //   onTap: () {
          //     // Navigate to account settings screen
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.lock),
          //   title: const Text("Privacy Policy"),
          //   onTap: () {
          //     // Navigate to privacy policy screen
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.info),
          //   title: const Text("About"),
          //   onTap: () {
          //     // Show app info
          //   },
          // ),
        ],
      ),
    );
  }
}
