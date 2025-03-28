import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/quotation_item.dart';
import '../util/calculation_utilities.dart';

Future<QuotationItem?> showBottomPopup(
    BuildContext context, {
      QuotationItem? existingItem,
    }) async {
  // Controllers for handling text input fields
  TextEditingController lengthController = TextEditingController(
    text: existingItem?.length.toString() ?? "",
  );
  TextEditingController widthController = TextEditingController(
    text: existingItem?.width.toString() ?? "",
  );
  TextEditingController heightController = TextEditingController(
    text: existingItem?.height?.toString() ?? "",
  );
  TextEditingController squareFootController = TextEditingController();
  TextEditingController rateController = TextEditingController(
    text: existingItem?.rate.toString() ?? "",
  );
  TextEditingController totalCostController = TextEditingController();
  TextEditingController itemNameController = TextEditingController(
    text: existingItem?.itemName ?? "",
  );
  TextEditingController quantityController = TextEditingController(
    text: existingItem?.quantity.toString() ?? "",
  );
  TextEditingController footController = TextEditingController(
    text: existingItem?.foot.toString() ?? "",
  );

  // Default values for unit and shape selections
  String selectedUnit = existingItem?.unit ?? "Feet";
  String selectedShape = existingItem?.shape ?? "Area";

  return showModalBottomSheet<QuotationItem>(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final themeProvider = Provider.of<ThemeProvider>(context);
      final isDarkMode = themeProvider.isDarkMode;
      return StatefulBuilder(
        builder: (context, setState) {
          bool isItemNameEmpty = false;

          void calculateTotalCost() {
            double squareFeet = double.tryParse(squareFootController.text) ?? 0;
            double rate = double.tryParse(rateController.text) ?? 0;
            double quantity = double.tryParse(quantityController.text) ?? 0;
            double totalCost = squareFeet * rate;
            if(selectedUnit == "N/A"){
              totalCost = quantity * rate;
            }
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
              quantity: double.tryParse(quantityController.text) ?? 0,
              unit: selectedUnit,
              shape: selectedShape,
              foot: double.tryParse(footController.text) ?? 0,
            );

            setState(() {
              squareFootController.text = result.toStringAsFixed(2);
              calculateTotalCost();
            });
          }

          // Trigger initial calculation when popup opens
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Prefill square feet and total cost for existing item
            squareFootController.text = existingItem?.squareFeet.toStringAsFixed(2) ?? '0.00';
            totalCostController.text = existingItem?.totalCost.toStringAsFixed(2) ?? '0.00';

            if (selectedUnit == "R. Foot") {
              footController.addListener(calculateSquareFoot);
              quantityController.addListener(calculateSquareFoot);
            }
            calculateSquareFoot();
          });

          void addCalculationListeners() {
            lengthController.addListener(calculateSquareFoot);
            widthController.addListener(calculateSquareFoot);
            heightController.addListener(calculateSquareFoot);
            rateController.addListener(calculateTotalCost);

            if (selectedUnit == "R. Foot") {
              footController.addListener(calculateSquareFoot);
              quantityController.addListener(calculateSquareFoot);
            }
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
                        existingItem != null ? "Edit Item Details" : "Enter Item Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                        errorText:
                        isItemNameEmpty ? "Item Name is required" : null,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: isItemNameEmpty ? Colors.red : Colors.blue,
                          ),
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
                          gapPadding: 10,
                        ),
                      ),
                      value: selectedUnit,
                      borderRadius: BorderRadius.circular(15),
                      dropdownColor: Colors.white,
                      menuMaxHeight: 300,
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      itemHeight: 50,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      elevation: 8,
                      selectedItemBuilder: (BuildContext context) {
                        return ["Inch", "Feet", "Meter", "R. Foot", "N/A"].map<Widget>((String unit) {
                          return Text(
                            unit,
                            style: isDarkMode ?
                              TextStyle(color: Colors.grey, fontSize: 16) :
                              TextStyle(color: Colors.black87, fontSize: 16),
                          );
                        }).toList();
                      },
                      items: ["Inch", "Feet", "Meter", "R. Foot", "N/A"].map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Container(
                            width: 100,
                            alignment: Alignment.centerLeft,
                            child: Text(unit),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedUnit = newValue!;
                          // Reset length, width, height, and shape based on unit
                          if (newValue == "N/A") {
                            selectedShape = "Area";
                            lengthController.clear();
                            widthController.clear();
                            heightController.clear();
                          } else if (newValue == "R. Foot") {
                            selectedShape = "Area";
                            lengthController.clear();
                            widthController.clear();
                            heightController.clear();
                          }
                          calculateSquareFoot(); // Ensure recalculation
                        });
                      },
                    ),

                    SizedBox(height: 10),

                    // Shape selection (Hidden for "N/A" and "R. Foot")
                    Visibility(
                      visible: selectedUnit != "N/A" && selectedUnit != "R. Foot",
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.category),
                              labelText: "Select Shape",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                gapPadding: 10,
                              ),
                            ),
                            value: selectedShape,
                            borderRadius: BorderRadius.circular(15),
                            dropdownColor: Colors.white,
                            menuMaxHeight: 200,
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            itemHeight: 50,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                            elevation: 8,
                            items: ["Area", "Cubic"].map((String shape) {
                              return DropdownMenuItem<String>(
                                value: shape,
                                child: Text(
                                    shape,
                                    style: isDarkMode?
                                    TextStyle(color: Colors.grey, fontSize: 16) :
                                    TextStyle(color: Colors.black87, fontSize: 16),),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedShape = newValue!;
                                if (newValue == "Area") {
                                  heightController.clear();
                                }
                                calculateSquareFoot();
                              });
                            },
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),

                    // Length, Width, Height (Hidden for "N/A" and "R. Foot")
                    Visibility(
                      visible: selectedUnit != "N/A" && selectedUnit != "R. Foot",
                      child: Column(
                        children: [
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
                        ],
                      ),
                    ),

                    // Foot field (Only shown for "R. Foot")
                    Visibility(
                      visible: selectedUnit == "R. Foot",
                      child: Column(
                        children: [
                          TextField(
                            controller: footController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.straighten),
                              labelText: "Foot",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              contentPadding: EdgeInsets.all(10),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),

                    // Qty and Sq Foot in the same row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: quantityController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.numbers),
                              labelText: "Qty",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              contentPadding: EdgeInsets.all(10),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 10),

                        // Sq Foot should be hidden when "N/A" is selected
                        Visibility(
                          visible: selectedUnit != "N/A",
                          child: Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: AutoSizeText(
                                "Sq. Foot: ${squareFootController.text}",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                maxLines: 1,
                                minFontSize: 10,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    // Rate (Always visible)
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

                    // Total Cost (Always visible)
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          isDarkMode ? Colors.white12 : Colors.white,
                          elevation: 10,
                        ),
                        onPressed: () {
                          if (itemNameController.text.isEmpty) {
                            setState(() {
                              isItemNameEmpty = true;
                            });
                            return;
                          }

                          // Create the QuotationItem with all entered data
                          final item = QuotationItem(
                            id:
                            existingItem?.id ??
                                DateTime.now().millisecondsSinceEpoch,
                            itemName: itemNameController.text,
                            unit: selectedUnit,
                            shape: selectedShape,
                            length: double.tryParse(lengthController.text) ?? 0,
                            width: double.tryParse(widthController.text) ?? 0,
                            height:
                            selectedShape == "Cubic"
                                ? double.tryParse(heightController.text)
                                : null,
                            squareFeet:
                            double.tryParse(squareFootController.text) ?? 0,
                            quantity:
                            int.tryParse(quantityController.text) ?? 0,
                            rate: double.tryParse(rateController.text) ?? 0,
                            totalCost:
                            double.tryParse(totalCostController.text) ?? 0,
                            foot: double.tryParse(footController.text) ?? 0,
                          );

                          // Close the popup and return the item
                          Navigator.of(context).pop(item);
                          print("Item ${existingItem != null ? 'updated' : 'added'}: ${item.itemName}");
                        },
                        child: Text(
                          existingItem != null ? "Update Item" : "Add Item",
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
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