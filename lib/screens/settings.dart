import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quotation/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/country_codes.dart';

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
  String selectedCountryCode = "+91"; // Default to India
  bool isLoading = true;

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
      selectedCountryCode = prefs.getString('countryCode') ?? "+91"; // Load country code

      firstNameController.text = savedFirstName;
      lastNameController.text = savedLastName;
      mobileNumberController.text = savedMobileNumber;

      isEditing = savedFirstName.isEmpty && savedLastName.isEmpty;
      isLoading = false;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', firstNameController.text);
    await prefs.setString('lastName', lastNameController.text);
    await prefs.setString('mobileNumber', mobileNumberController.text);
    await prefs.setString('countryCode', selectedCountryCode); // Save country code
  }

  void toggleEditMode() {
    if (isEditing) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          savedFirstName = firstNameController.text;
          savedLastName = lastNameController.text;
          savedMobileNumber = mobileNumberController.text;
          isEditing = false;
          _saveData();
        });
      }
    } else {
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
    // final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    Color getBorderColor(bool isEditing) {
      return isEditing ? Colors.blue : Colors.grey;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: iconColor))
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
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
            Divider(thickness: 1, color: Colors.grey),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Profile",
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: toggleEditMode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.white12 : Colors.white,
                    foregroundColor: Colors.white,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(10),
                  ),
                  child: Icon(
                    isEditing ? Icons.save : Icons.edit,
                    size: 20,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            SizedBox(height: 15),

            // First Name & Last Name (With Prefix Icons)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: firstNameController,
                    readOnly: !isEditing,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: getBorderColor(isEditing)),
                      labelText: "First Name",
                      labelStyle: TextStyle(color: getBorderColor(isEditing)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: getBorderColor(isEditing)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: getBorderColor(isEditing), width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: getBorderColor(isEditing)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'First name is required';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: lastNameController,
                    readOnly: !isEditing,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person_outline, color: getBorderColor(isEditing)),
                      labelText: "Last Name",
                      labelStyle: TextStyle(color: getBorderColor(isEditing)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: getBorderColor(isEditing)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: getBorderColor(isEditing), width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: getBorderColor(isEditing)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Last name is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            // Mobile Number with Country Code using IntlPhoneField
            IntlPhoneField(
              controller: mobileNumberController,
              initialCountryCode: countryCodeToIso[selectedCountryCode]?.first ?? 'IN',
              enabled: isEditing,
              decoration: InputDecoration(
                labelText: "Mobile Number",
                labelStyle: TextStyle(color: getBorderColor(isEditing)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: getBorderColor(isEditing)),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: getBorderColor(isEditing)),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: getBorderColor(isEditing)),
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: getBorderColor(isEditing)),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
              dropdownTextStyle: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
              onChanged: (phone) {
                if (isEditing) {
                  setState(() {
                    mobileNumberController.text = phone.number;
                    selectedCountryCode = phone.countryCode;
                  });
                }
              },
              onCountryChanged: (country) {
                if (isEditing) {
                  setState(() {
                    selectedCountryCode = country.dialCode;
                  });
                }
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
