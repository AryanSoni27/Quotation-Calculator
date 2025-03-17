import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quotation/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isEditing = true;
  String savedFirstName = "";
  String savedLastName = "";
  String savedMobileNumber = "";
  bool isLoading = true;

  // Individual colors for each field
  final Color firstNameColor = Colors.blue;
  final Color lastNameColor = Colors.blue;
  final Color mobileColor = Colors.blue;
  final Color iconColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedFirstName = prefs.getString('firstName') ?? "";
      savedLastName = prefs.getString('lastName') ?? "";
      savedMobileNumber = prefs.getString('mobileNumber') ?? "";

      firstNameController.text = savedFirstName;
      lastNameController.text = savedLastName;
      mobileNumberController.text = savedMobileNumber;

      // If we have saved data, start in view mode
      isEditing = savedFirstName.isEmpty && savedLastName.isEmpty;
      isLoading = false;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', firstNameController.text);
    await prefs.setString('lastName', lastNameController.text);
    await prefs.setString('mobileNumber', mobileNumberController.text);
  }

  void toggleEditMode() {
    if (isEditing) {
      // Validate before saving
      if (_formKey.currentState!.validate()) {
        setState(() {
          savedFirstName = firstNameController.text;
          savedLastName = lastNameController.text;
          savedMobileNumber = mobileNumberController.text;
          isEditing = false;
          _saveData(); // Save data when form is submitted
        });
      }
    } else {
      // Switch back to editing mode
      setState(() {
        firstNameController.text = savedFirstName;
        lastNameController.text = savedLastName;
        mobileNumberController.text = savedMobileNumber;
        isEditing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: iconColor))
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Dark mode switch
            ListTile(
              leading: Icon(Icons.dark_mode, color: iconColor),
              title: const Text("Dark Mode"),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (bool value) async {
                  themeProvider.toggleDarkMode();
                },
                activeColor: iconColor,
              ),
            ),

            SizedBox(height: 20),

            // First name and last name fields
            Row(
              children: [
                Expanded(
                  child: isEditing
                      ? TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: "First Name",
                      labelStyle: TextStyle(color: firstNameColor),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: firstNameColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: firstNameColor, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: firstNameColor),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'First name is required';
                      }
                      return null;
                    },
                  )
                      : Text("First Name: ${firstNameController.text}",
                      style: TextStyle(color: firstNameColor)),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: isEditing
                      ? TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: "Last Name",
                      labelStyle: TextStyle(color: lastNameColor),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: lastNameColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: lastNameColor, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: lastNameColor),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Last name is required';
                      }
                      return null;
                    },
                  )
                      : Text("Last Name: ${lastNameController.text}",
                      style: TextStyle(color: lastNameColor)),
                ),
              ],
            ),

            SizedBox(height: 10),

            // Mobile number field
            isEditing
                ? TextFormField(
              controller: mobileNumberController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                labelText: "Mobile Number",
                labelStyle: TextStyle(color: mobileColor),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: mobileColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: mobileColor, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: mobileColor),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Mobile number is required';
                }
                if (value.length != 10) {
                  return 'Mobile number must be exactly 10 digits';
                }
                return null;
              },
            )
                : Text("Mobile Number: ${mobileNumberController.text}",
                style: TextStyle(color: mobileColor)),

            SizedBox(height: 20),

            // Submit/Edit button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: toggleEditMode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(isEditing ? "Submit" : "Edit",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}