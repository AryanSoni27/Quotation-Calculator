import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'pdf_generator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quotation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Quotation'),
    );
  }
}

class QuotationItem {
  final String itemName;
  final String unit;
  final String shape;
  final double length;
  final double width;
  final double? height;
  final double squareFeet;
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
    required this.rate,
    required this.totalCost,
  });
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FormController formController = FormController();
  String? selectedShape;
  String? selectedUnit;
  List<QuotationItem> items = [];

  @override
  void dispose() {
    formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //Customer Name Field
              TextField(
                controller: formController.customerNameController,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: "Customer Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
              SizedBox(height: 20),

              //Date Picker Field
              TextField(
                controller: formController.dateController,
                // controller: datePickerController,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_month),
                  labelText: "Date",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.all(10),
                ),
                onTap: () => onTapFunction(context: context, formController: formController),
              ),
              SizedBox(height: 20),

              // Project Name Field
              TextField(
                controller: formController.projectNameController,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.shopping_bag_sharp),
                  labelText: "Project Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
              SizedBox(height: 20),

              // Mobile Number Field
              TextField(
                controller: formController.mobileNumberController,
                textAlign: TextAlign.left,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone),
                  labelText: "Mobile Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.all(10),
                ),
              ),

              if (items.isNotEmpty) ...[
                SizedBox(height: 20),
                Text(
                  "Added Items:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(item.itemName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Measurements: ${item.length} × ${item.width}${item.height != null ? ' × ${item.height}' : ''} ${item.unit}'),
                            Text('Area: ${item.squareFeet.toStringAsFixed(2)} sq ft'),
                            Text('Rate: ${item.rate.toStringAsFixed(2)}'),
                            Text('Total: ${item.totalCost.toStringAsFixed(2)}'),
                          ],
                        ),
                        //Added delete button for each item
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              items.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],

              SizedBox(height: 40),

              //Button to add items
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: Size(40, 40)),
                  onPressed: () async {
                    //Wait for and handle the result from bottom popup
                    final result = await _showBottomPopup(context);
                    if (result != null) {
                      setState(() {
                        items.add(result);
                      });
                    }
                  },
                  child: Text("Add Item"),
                ),
              ),
              SizedBox(height: 30),

              //Submit Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: Size(200, 40)),
                  onPressed: () {
                    generatePdf(
                      customerName: formController.customerNameController.text,
                      date: formController.dateController.text,
                      projectName: formController.projectNameController.text,
                      mobileNumber: formController.mobileNumberController.text,
                      items: items,
                    );
                  },

                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//This method will generate the date picker when user tab on date field
TextEditingController datePickerController = TextEditingController();

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

//This Method will generate the bottom popup menu when user tap on Add Item button and
//it gives user options to enter the details
// and handles all calculations for area and volume measurements
Future<QuotationItem?> _showBottomPopup(BuildContext context) async {
  // Controllers for handling text input fields
  TextEditingController lengthController = TextEditingController();
  TextEditingController widthController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController squareFootController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  TextEditingController totalCostController = TextEditingController();
  TextEditingController itemNameController = TextEditingController();
  // Default values for unit and shape selections
  String selectedUnit = "Feet";
  String selectedShape = "Area";

  return showModalBottomSheet<QuotationItem>(
    context: context,
    isScrollControlled: true, // Allows the sheet to take full height if needed
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {

          //This Function will calculate the total cost based on rate and square foot
          void calculateTotalCost() {
            double squareFeet = double.tryParse(squareFootController.text) ?? 0;
            double rate = double.tryParse(rateController.text) ?? 0;
            double totalCost = squareFeet * rate;

            setState(() {
              totalCostController.text = totalCost.toStringAsFixed(2);
            });
          }
          // Calculate the square footage based on input values and selected options
          void calculateSquareFoot() {
            // Parse input values, default to 0 if parsing fails
            double length = double.tryParse(lengthController.text) ?? 0;
            double width = double.tryParse(widthController.text) ?? 0;
            double height = double.tryParse(heightController.text) ?? 0;

            // Calculate result using the unified calculation method
            // This ensures consistent unit conversion regardless of input unit
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

          //Add listeners to text controllers for real-time calculation updates
          void addCalculationListeners() {
            lengthController.addListener(calculateSquareFoot);
            widthController.addListener(calculateSquareFoot);
            // Only add height listener if we're calculating volume
            if (selectedShape == "Cubic") {
              heightController.addListener(calculateSquareFoot);
            }
            rateController.addListener(calculateTotalCost);
          }

          //Clean up listeners to prevent memory leaks and unexpected behavior
          void removeCalculationListeners() {
            lengthController.removeListener(calculateSquareFoot);
            widthController.removeListener(calculateSquareFoot);
            heightController.removeListener(calculateSquareFoot);
            rateController.removeListener(calculateTotalCost);
          }

          //Initialize listeners when building the widget
          addCalculationListeners();

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, // Adjusts for keyboard
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
                        prefixIcon: Icon(Icons.shopping_bag_rounded),
                        labelText: "Item Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Unit selection dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.straighten),
                        labelText: "Unit of Measurement",
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
                    TextField(
                      controller: squareFootController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.square_foot),
                        labelText: "Square Foot",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      readOnly: true, // User can't edit the result
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
                          // Validate required fields
                          if (itemNameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please enter item name')),
                            );
                            return;
                          }

                          // Create the QuotationItem with all entered data
                          final item = QuotationItem(
                            itemName: itemNameController.text, // Use the controller value
                            unit: selectedUnit,
                            shape: selectedShape,
                            length: double.tryParse(lengthController.text) ?? 0,
                            width: double.tryParse(widthController.text) ?? 0,
                            height: selectedShape == "Cubic"
                                ? double.tryParse(heightController.text)
                                : null,
                            squareFeet: double.tryParse(squareFootController.text) ?? 0,
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

// Calculates the final measurement based on input values and selected options
// Returns the result in square feet (for area) or cubic feet (for volume)
double calculateMeasurement({
  required double length,
  required double width,
  required double height,
  required String unit,
  required String shape,
}) {
  // Convert all measurements to feet before calculating
  double lengthInFeet = convertToFeet(length, unit);
  double widthInFeet = convertToFeet(width, unit);
  double heightInFeet = convertToFeet(height, unit);

  // Calculate based on selected shape
  if (shape == "Area") {
    return lengthInFeet * widthInFeet; // Returns square feet
  } else if (shape == "Cubic") {
    return lengthInFeet * widthInFeet * heightInFeet; // Returns cubic feet
  }
  return 0;
}

// Converts any input measurement to feet based on the selected unit
double convertToFeet(double length, String unit) {
  if (unit == "Feet") {
    return length; // Already in feet
  } else if (unit == "Inch") {
    return length / 12; // Convert inches to feet
  } else if (unit == "Meter") {
    return length * 3.28084; // Convert meters to feet
  }
  return length; // Default return if unit is not recognized
}





