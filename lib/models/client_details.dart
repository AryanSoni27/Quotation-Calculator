import 'package:flutter/material.dart';

class ClientDetails {
  final String firstName;
  final String lastName;
  final String mobileNumber;
  final String countryCode;
  final String streetAddress;
  final String city;
  final String pinCode;
  final String state;

  ClientDetails({
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    this.countryCode = '+91',
    required this.streetAddress,
    required this.city,
    required this.pinCode,
    required this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'mobileNumber': mobileNumber,
      'countryCode': countryCode,
      'streetAddress': streetAddress,
      'city': city,
      'pinCode': pinCode,
      'state': state,
    };
  }

  factory ClientDetails.fromJson(Map<String, dynamic> json) {
    return ClientDetails(
      firstName: json['firstName'],
      lastName: json['lastName'],
      mobileNumber: json['mobileNumber'],
      countryCode: json['countryCode'],
      streetAddress: json['streetAddress'],
      city: json['city'],
      pinCode: json['pinCode'],
      state: json['state'],
    );
  }
}


class ClientDetailsFormController {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  String countryCodeController = '+91';
  final TextEditingController streetAddressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController stateController = TextEditingController();

  bool isMobileValid = true;

  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    mobileNumberController.dispose();
    // countryCodeController.dispose();
    streetAddressController.dispose();
    cityController.dispose();
    pinCodeController.dispose();
    stateController.dispose();
  }
}