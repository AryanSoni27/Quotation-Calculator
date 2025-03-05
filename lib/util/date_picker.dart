import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/quotation_item.dart';

onTapFunction({required BuildContext context, required FormController formController}) async {
  DateTime? pickedDate = await showDatePicker(
    context: context,
    lastDate: DateTime(2050),
    firstDate: DateTime(1970),
    initialDate: DateTime.now(),
  );
  if (pickedDate == null) return;
  String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);

  formController.dateController.text = formattedDate;

  (context as Element).markNeedsBuild();
}