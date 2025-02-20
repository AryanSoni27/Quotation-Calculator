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
              Text("Customer"),
              SizedBox(height: 5),
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

              Text("Date"),
              SizedBox(height: 5),
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

              Text("Project"),
              SizedBox(height: 5),
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

              Text("Mobile Number"),
              SizedBox(height: 5),
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
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Enter Item Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text("Item"),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.shopping_bag_sharp),
                    labelText: "Item Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text("Unit"),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.construction),
                    labelText: "Unit",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text("Measurement"),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.construction),
                    labelText: "Measurement",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                Text("Square Foot"),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.square_foot),
                    labelText: "Sq Foot",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                Text("Rate"),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.currency_rupee),
                    labelText: "Rate",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text("Total Cost"),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.currency_rupee),
                    labelText: "Total Cost",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Add Item"),
                ),
                SizedBox(height: 10),
              ],
            ),
          ],
        ),
      );
    },
  );
}