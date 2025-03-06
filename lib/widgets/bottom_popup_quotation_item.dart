import 'package:flutter/material.dart';
import '../models/quotation_item.dart';
import '../util/calculation_utilities.dart';

Future<QuotationItem?> showBottomPopup(BuildContext context, {QuotationItem? existingItem}) async {
  // Controllers for handling text input fields
  TextEditingController lengthController = TextEditingController(text: existingItem?.length.toString() ?? "");
  TextEditingController widthController = TextEditingController(text: existingItem?.width.toString() ?? "");
  TextEditingController heightController = TextEditingController(text: existingItem?.height?.toString() ?? "");
  TextEditingController squareFootController = TextEditingController();
  TextEditingController rateController = TextEditingController(text: existingItem?.rate.toString() ?? "");
  TextEditingController totalCostController = TextEditingController();
  TextEditingController itemNameController = TextEditingController(text: existingItem?.itemName ?? "");
  TextEditingController quantityController = TextEditingController(text: existingItem?.quantity.toString() ?? "");

  // Default values for unit and shape selections
  String selectedUnit = "Feet";
  String selectedShape = "Area";

  return showModalBottomSheet<QuotationItem>(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          bool isItemNameEmpty = false;

          void calculateTotalCost() {
            double squareFeet = double.tryParse(squareFootController.text) ?? 0;
            double rate = double.tryParse(rateController.text) ?? 0;
            double quantity = double.tryParse(quantityController.text) ?? 0;
            double totalCost = squareFeet * rate * quantity;

            setState(() {
              totalCostController.text = totalCost.toStringAsFixed(2);
            });
          }

          void calculateSquareFoot() {
            double length = double.tryParse(lengthController.text) ?? 0;
            double width = double.tryParse(widthController.text) ?? 0;
            double height = double.tryParse(heightController.text) ?? 0;

            double result = calculateMeasurement(
              length: length,
              width: width,
              height: height,
              unit: selectedUnit,
              shape: selectedShape,
            );

            setState(() {
              squareFootController.text = result.toStringAsFixed(2);
              calculateTotalCost();
            });
          }

          void addCalculationListeners() {
            lengthController.addListener(calculateSquareFoot);
            widthController.addListener(calculateSquareFoot);
            if (selectedShape == "Cubic") {
              heightController.addListener(calculateSquareFoot);
            }
            rateController.addListener(calculateTotalCost);
          }

          void removeCalculationListeners() {
            lengthController.removeListener(calculateSquareFoot);
            widthController.removeListener(calculateSquareFoot);
            heightController.removeListener(calculateSquareFoot);
            rateController.removeListener(calculateTotalCost);
          }

          addCalculationListeners();

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Wrap(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title of the popup
                    Center(
                      child: Text(
                        "Enter Item Details",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Item Name input field
                    TextField(
                      controller: itemNameController,
                      decoration: InputDecoration(
                        labelText: "Item Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        errorText: isItemNameEmpty ? "Item Name is required" : null,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: isItemNameEmpty ? Colors.red : Colors.blue),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          isItemNameEmpty = value.isEmpty;
                        });
                      },
                    ),
                    SizedBox(height: 10),

                    // Unit selection dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.straighten),
                        labelText: "Measurement Unit",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      value: selectedUnit,
                      items: ["Inch", "Feet", "Meter"].map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      //Updated to recalculate when unit changes
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedUnit = newValue!;
                          calculateSquareFoot(); // Recalculate with new unit
                        });
                      },
                    ),
                    SizedBox(height: 10),

                    // Shape selection dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.category),
                        labelText: "Select Shape",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      value: selectedShape,
                      items: ["Area", "Cubic"].map((String shape) {
                        return DropdownMenuItem<String>(
                          value: shape,
                          child: Text(shape),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        removeCalculationListeners();
                        setState(() {
                          selectedShape = newValue!;
                          calculateSquareFoot();
                        });
                        addCalculationListeners();
                      },
                    ),
                    SizedBox(height: 10),

                    // Measurement input fields
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: lengthController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.straighten),
                              labelText: "Length",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              contentPadding: EdgeInsets.all(10),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: widthController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.straighten),
                              labelText: "Width",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              contentPadding: EdgeInsets.all(10),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        // Conditional height field for cubic measurements
                        if (selectedShape == "Cubic") ...[
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: heightController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.height),
                                labelText: "Height",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                contentPadding: EdgeInsets.all(10),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 10),

                    // Result field showing calculated square foot
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: squareFootController,
                            decoration: InputDecoration(
                              // prefixIcon: Icon(Icons.square_foot),
                              prefixText: "SquareFoot: ",
                              prefixStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                              // labelText: "Square Foot",
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                            keyboardType: TextInputType.number,
                            readOnly: true, // User can't edit the result
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: quantityController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.numbers),
                              labelText: "Quantity",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              // contentPadding: EdgeInsets.all(10),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    // Rate input field for price per square foot
                    TextField(
                      controller: rateController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.currency_rupee),
                        labelText: "Rate",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        contentPadding: EdgeInsets.all(10),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),

                    // Total cost field (calculated from rate * square footage)
                    TextField(
                      controller: totalCostController,
                      readOnly: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.currency_rupee),
                        labelText: "Total Cost",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        contentPadding: EdgeInsets.all(10),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),

                    // Add item button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (itemNameController.text.isEmpty) {
                            setState(() {
                              isItemNameEmpty = true;
                            });
                            return;
                          }

                          // Create the QuotationItem with all entered data
                          final item = QuotationItem(
                            itemName: itemNameController.text,
                            unit: selectedUnit,
                            shape: selectedShape,
                            length: double.tryParse(lengthController.text) ?? 0,
                            width: double.tryParse(widthController.text) ?? 0,
                            height: selectedShape == "Cubic"
                                ? double.tryParse(heightController.text)
                                : null,
                            squareFeet: double.tryParse(squareFootController.text) ?? 0,
                            quantity: int.tryParse(quantityController.text) ?? 0,
                            rate: double.tryParse(rateController.text) ?? 0,
                            totalCost: double.tryParse(totalCostController.text) ?? 0,
                          );

                          // Close the popup and return the item
                          Navigator.of(context).pop(item);
                        },
                        child: Text("Add Item"),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}