import 'package:flutter/material.dart';

class QuotationItem {
  final String itemName;
  final String unit;
  final String shape;
  final double length;
  final double width;
  final double? height;
  final double squareFeet;
  final int quantity;
  final double rate;
  final double totalCost;

  QuotationItem({
    required this.itemName,
    required this.unit,
    required this.shape,
    required this.length,
    required this.width,
    this.height,
    required this.squareFeet,
    required this.quantity,
    required this.rate,
    required this.totalCost,
  });
}

class FormController {
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();

  void dispose() {
    customerNameController.dispose();
    dateController.dispose();
    projectNameController.dispose();
    mobileNumberController.dispose();
  }
}