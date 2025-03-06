import 'package:flutter/material.dart';

class ClientDetails {
  final String firstName;
  final String lastName;
  final String mobileNumber;
  final String address;

  ClientDetails({
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    required this.address,
  });
}

class ClientDetailsFormController {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    mobileNumberController.dispose();
    addressController.dispose();
  }
}