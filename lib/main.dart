import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? selectedShape;
  String? selectedUnit;
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
                controller: datePickerController,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_month),
                  labelText: "Date",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.all(10),
                ),
                onTap: () => onTapFunction(context: context),
              ),
              SizedBox(height: 20),

              // Project Name Field
              TextField(
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

              SizedBox(height: 40),

              //Button to add items
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: Size(40, 40)),
                  onPressed: () {
                    _showBottomPopup(context);
                  },
                  child: Text("Add Item"),
                ),
              ),
              SizedBox(height: 30),

              //Submit Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: Size(200, 40)),
                  onPressed: () {},
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

onTapFunction({required BuildContext context}) async {
  DateTime? pickedDate = await showDatePicker(
    context: context,
    lastDate: DateTime(2050),
    firstDate: DateTime(1970),
    initialDate: DateTime.now(),
  );
  if (pickedDate == null) return;
  datePickerController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
}

//This Method will generate the bottom popup menu when user tap on Add Item button and
//it gives user options to enter the details
void _showBottomPopup(BuildContext context) {
  TextEditingController lengthController = TextEditingController();
  TextEditingController widthController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController squareFootController = TextEditingController();
  String selectedUnit = "Feet";
  String selectedShape = "Area";
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          void calculateSquareFoot() {
            double length = double.tryParse(lengthController.text) ?? 0;
            double width = double.tryParse(widthController.text) ?? 0;
            double height = double.tryParse(heightController.text) ?? 0;
            double result = 0;

            if (selectedShape == "Area") {
              result = length * width;
            } else if (selectedShape == "Cubic") {
              result = length * width * height;
            }

            setState(() {
              squareFootController.text = result.toStringAsFixed(2);
            });
          }
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
                    Center(
                      child: Text(
                        "Enter Item Details",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Item Name Field
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.shopping_bag_sharp),
                        labelText: "Item Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Unit of Measurement Field
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
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedUnit = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 10),

                    // Field to select the shape
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
                        setState(() {
                          selectedShape = newValue!;
                          calculateSquareFoot();
                        });
                      },
                    ),
                    SizedBox(height: 10),

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

                    // Square Foot Field
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
                      readOnly: true,
                    ),
                    SizedBox(height: 10),

                    // Rate Field, here we are going to insert the rate per square foot
                    TextField(
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

                    // Total Cost field, here total cost will be calculated
                    TextField(
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

                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
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

double calculateMeasurement({
  required double length,
  required double width,
  required double height,
  required String unit,
  required String shape,
}) {
  double lengthInFeet = convertToFeet(length, unit);
  double widthInFeet = convertToFeet(width, unit);
  double heightInFeet = convertToFeet(height, unit);

  if (shape == "Area") {
    return lengthInFeet * widthInFeet;
  } else if (shape == "Cubic") {
    return lengthInFeet * widthInFeet * heightInFeet;
  }

  return 0;
}

double convertToFeet(double length, String unit) {
  double result = 0;
  if (unit == "Feet") {
    result = length;
  } else if (unit == "Inch") {
    result = length * 12;
  } else if (unit == "Meter"){
    result = length * 3.28084;
  }
  return result;
}




