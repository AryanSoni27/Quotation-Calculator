import 'package:flutter/material.dart';

class QuotationItem {
  final int id;
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
    required this.id,
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

  // Create a copy of the item with updated values
  QuotationItem copyWith({
    int? id,
    String? itemName,
    String? unit,
    String? shape,
    double? length,
    double? width,
    double? height,
    double? squareFeet,
    int? quantity,
    double? rate,
    double? totalCost,
  }) {
    return QuotationItem(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      unit: unit ?? this.unit,
      shape: shape ?? this.shape,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      squareFeet: squareFeet ?? this.squareFeet,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      totalCost: totalCost ?? this.totalCost,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'itemName': itemName,
      'unit': unit,
      'shape': shape,
      'length': length,
      'width': width,
      if (height != null) 'height': height,
      'squareFeet': squareFeet,
      'quantity': quantity,
      'rate': rate,
      'totalCost': totalCost,
    };
  }
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