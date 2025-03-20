# Quotation Calculator

## 📌 Project Overview
Quotation Calculator is a Flutter-based application that calculates quotations based on measurements and generates PDF files. This project is designed to simplify quotation generation for businesses, helping them save time and reduce manual work.

## 🚀 Features
- 📏 Measurement-based quotation calculations
- 📄 PDF generation for quotations
- 🔒 Secure access with authentication (planned feature)
- ☁️ Cloud backup & sync (planned feature)

## 🛠️ Tech Stack
- **Flutter** (Frontend UI)
- **Dart** (Programming Language)
- **PDF Package** (For PDF generation)

## 📥 Installation
1. Clone this repository:
   ```bash
   git clone https://github.com/AryanSoni27/Quotation-Calculator.git
   ```
2. Navigate to the project directory:
   ```bash
   cd quotation-calculator
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

## 📂 Folder Structure
```
quotation-calculator/
│-- lib/
   |--data/
      |--db_helper_quotation.dart
      |--db_helper_quotation_screen.dart
   |-- models/
      |--client_details.dart
      |--quotation_item.dart
      |--quotation_screen.dart
   |--screens/
      |--clients.dart
      |--home_screen.dart
      |--quotations.dart
      |--settings.dart
   |--services/
      |--pdf_generator.dart
   |util/
      |--calculation_utilities.dart
      |--date_picker.dart
   |widgets/
      |--bottom_navigation_bar.dart
      |--bottom_popup_client_details.dart
      |--bottom_popup_quotation_item.dart
   │-- main.dart
│-- assets/
│-- pubspec.yaml
│-- README.md
```

## 🛠️ Future Enhancements
- [ ] User authentication
- [ ] Cloud storage for quotations
- [ ] Multi-language support
- [ ] Role-based access control

## 🤝 Contributing
Contributions are welcome! Feel free to fork this repository and submit pull requests.

## 📧 Contact
For any queries or feedback, reach out to me at [aryansoni33635@gmail.com].

