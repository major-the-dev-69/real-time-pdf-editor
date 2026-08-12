

import 'country_list_picker.dart';

class FormValidator {
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Name is required";
    }
    if (value.trim().length < 3) {
      return "Name must be at least 3 characters";
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return "Name can only contain alphabets";
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value.trim())) {
      return "Enter a valid email";
    }
    return null;
  }

  static String? walletName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Wallet name is required";
    }
    // Allow letters, numbers, spaces, and underscores, min length 3
    if (!RegExp(r'^[a-zA-Z0-9 _]{3,30}$').hasMatch(value.trim())) {
      return "Enter a valid wallet name (3–30 characters)";
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters";
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return "Confirm Password is required";
    }
    if (value != password) {
      return "Passwords do not match";
    }
    return null;
  }

  static String? dob(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Date of Birth is required";
    }
    // Simple date validation (dd/MM/yyyy or yyyy-MM-dd)
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value.trim()) &&
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value.trim())) {
      return "Enter a valid date (dd/MM/yyyy or yyyy-MM-dd)";
    }
    return null;
  }

  static String? validateAadhaar(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter Aadhaar number";
    } else if (value.length != 12) {
      return "Aadhaar number must be 12 digits";
    } else if (!RegExp(r'^[0-9]{12}$').hasMatch(value)) {
      return "Invalid Aadhaar number";
    }
    return null; // valid
  }

  static String? mobile(String? value, {required Country country}) {
    int minLength = country.minLength;
    int maxLength = country.maxLength;

    if (value == null || value.trim().isEmpty) {
      return "Mobile number is required";
    }

    String mobile = value.trim();

    // Check minimum length
    if (mobile.length < minLength) {
      return "Mobile number must be at least $minLength digits";
    }

    // Check maximum length
    if (mobile.length > maxLength) {
      return "Mobile number must not exceed $maxLength digits";
    }

    // Only digits allowed
    if (!RegExp(r'^[0-9]+$').hasMatch(mobile)) {
      return "Mobile number can contain digits only";
    }

    // Optional India-specific rule when min & max = 10
    if (minLength == 10 && maxLength == 10) {
      if (!RegExp(r'^[6-9]').hasMatch(mobile)) {
        return "Enter a valid Indian mobile number";
      }
    }

    return null;
  }
}
