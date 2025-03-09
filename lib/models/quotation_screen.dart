import 'package:quotation/models/quotation_item.dart';

class Quotation {
  final String id;
  final String customerName;
  final String date;
  final String projectName;
  final String mobileNumber;
  final List<QuotationItem> items;
  final double totalAmount;

  Quotation({
    required this.id,
    required this.customerName,
    required this.date,
    required this.projectName,
    required this.mobileNumber,
    required this.items,
    required this.totalAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'date': date,
      'projectName': projectName,
      'mobileNumber': mobileNumber,
      'totalAmount': totalAmount,
    };
  }

  static Quotation fromMap(Map<String, dynamic> map, List<QuotationItem> items) {
    return Quotation(
      id: map['id'],
      customerName: map['customerName'],
      date: map['date'],
      projectName: map['projectName'],
      mobileNumber: map['mobileNumber'],
      items: items,
      totalAmount: map['totalAmount'],
    );
  }
}