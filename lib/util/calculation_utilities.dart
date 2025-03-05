// Converts any input measurement to feet based on the selected unit
double convertToFeet(double length, String unit) {
  switch (unit) {
    case "Feet":
      return length;
    case "Inch":
      return length / 12;
    case "Meter":
      return length * 3.28084;
    default:
      return length;
  }
}

// Calculates the final measurement based on input values and selected options
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