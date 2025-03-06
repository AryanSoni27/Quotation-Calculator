import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:quotation/screens/clients.dart';
import 'package:quotation/screens/home_screen.dart';
import 'package:quotation/screens/quotations.dart';
import 'package:quotation/screens/settings.dart';
import 'package:quotation/widgets/bottom_navigation_bar.dart';
import 'models/quotation_item.dart';
import 'package:quotation/util/date_picker.dart';
import 'widgets/bottom_popup.dart';
import 'services/pdf_generator.dart';

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
  final FormController formController = FormController();
  List<QuotationItem> items = [];
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    HomeScreen(),
    Quotations(),
    Clients(),
    Settings(),
  ];

  bool _customerNameValid = true;
  bool _dateValid = true;
  bool _projectNameValid = true;
  bool _mobileNumberValid = true;

  final FocusNode _customerNameFocusNode = FocusNode();
  final FocusNode _dateFocusNode = FocusNode();
  final FocusNode _projectNameFocusNode = FocusNode();
  final FocusNode _mobileNumberFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _setupFocusListeners();
  }

  void _setupFocusListeners() {
    _customerNameFocusNode.addListener(() {
      if (!_customerNameFocusNode.hasFocus) {
        setState(() {
          _customerNameValid =
              formController.customerNameController.text.trim().isNotEmpty;
        });
      }
    });

    _dateFocusNode.addListener(() {
      if (!_dateFocusNode.hasFocus) {
        setState(() {
          _dateValid = formController.dateController.text.trim().isNotEmpty;
        });
      }
    });

    _projectNameFocusNode.addListener(() {
      if (!_projectNameFocusNode.hasFocus) {
        setState(() {
          _projectNameValid =
              formController.projectNameController.text.trim().isNotEmpty;
        });
      }
    });

    _mobileNumberFocusNode.addListener(() {
      if (!_mobileNumberFocusNode.hasFocus) {
        setState(() {
          _mobileNumberValid =
              formController.mobileNumberController.text.trim().length == 10;
        });
      }
    });
  }

  Future<bool> validateFields() async {
    setState(() {
      _customerNameValid =
          formController.customerNameController.text.trim().isNotEmpty;
      _dateValid = formController.dateController.text.trim().isNotEmpty;
      _projectNameValid =
          formController.projectNameController.text.trim().isNotEmpty;
      _mobileNumberValid =
          formController.mobileNumberController.text.trim().length == 10;
    });

    bool hasErrors = false;

    if (!_customerNameValid ||
        !_dateValid ||
        !_projectNameValid ||
        !_mobileNumberValid) {
      hasErrors = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }

    if (items.isEmpty) {
      if (!hasErrors) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please add at least one item to the quotation'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
      hasErrors = true;
    }

    return !hasErrors;
  }

  @override
  void dispose() {
    formController.dispose();
    _customerNameFocusNode.dispose();
    _dateFocusNode.dispose();
    _projectNameFocusNode.dispose();
    _mobileNumberFocusNode.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
