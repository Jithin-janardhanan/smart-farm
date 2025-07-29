// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:smartfarm/model/profile_model.dart';
// import 'package:smartfarm/service/api_service.dart';
// import 'package:smartfarm/view/login_view.dart';

// class ProfileController extends GetxController {
//   var farmer = Rxn<Farmer>();
//   var isLoading = false.obs;

//   final firstNamecrl = TextEditingController();

//   final lastNamecrl = TextEditingController();
//   final phoneNumbercrl = TextEditingController();
//   final emailcrl = TextEditingController();
//   final aadharNumbercrl = TextEditingController();
//   final houseNamecrl = TextEditingController();
//   final villagecrl = TextEditingController();
//   final districtcrl = TextEditingController();
//   final statecrl = TextEditingController();
//   final pincodecrl = TextEditingController();

//   @override
//   void onInit() {
//     super.onInit();
//     fetchProfile();
//   }

//   Future<void> fetchProfile() async {
//     isLoading.value = true;
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       final profile = await ApiService.getFarmerProfile(token);
//       farmer.value = profile;
//       firstNamecrl.text = profile.firstName;
//       lastNamecrl.text = profile.lastName;
//       phoneNumbercrl.text = profile.phoneNumber;
//       emailcrl.text = profile.email;
//       aadharNumbercrl.text = profile.aadharNumber;
//       houseNamecrl.text = profile.houseName;
//       villagecrl.text = profile.village;
//       districtcrl.text = profile.district;
//       statecrl.text = profile.state;
//       pincodecrl.text = profile.pincode;
//     } catch (e) {
//       log('message: $e');
//       Get.snackbar("Error", e.toString());
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> updateProfile() async {
//     isLoading.value = true;
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';

//       Farmer updated = Farmer(
//         id: farmer.value!.id,
//         username: farmer.value!.username,
//         firstName: firstNamecrl.text,
//         lastName: lastNamecrl.text,
//         email: emailcrl.text,
//         phoneNumber: phoneNumbercrl.text,
//         aadharNumber: aadharNumbercrl.text,
//         houseName: houseNamecrl.text,
//         village: villagecrl.text,
//         district: districtcrl.text,
//         state: statecrl.text,
//         pincode: pincodecrl.text,
//       );

//       final success = await ApiService.updateFarmerProfile(token, updated);
//       if (success) {
//         Get.snackbar("Success", "Profile updated successfully");
//         fetchProfile(); // Refresh the data
//       }
//     } catch (e) {
//       Get.snackbar("Error", e.toString());
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // Update path to your login screen

//   Future<void> logout() async {
//     isLoading.value = true;

//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';

//     try {
//       String message = await ApiService.logoutUser(token);
//       // Show success snackbar only if API call succeeds
//       Get.snackbar("Success", message, snackPosition: SnackPosition.BOTTOM);
//     } catch (e) {
//       await prefs.remove('token');

//       // Navigate to login
//       Get.offAll(() => LoginPage());
//       // Show error but don't prevent logout
//       Get.snackbar(
//         "Logout Warning",
//         "Logged out locally, but server logout failed",
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//       );
//     }

//     // Always clear token and navigate - regardless of API response

//     isLoading.value = false;
//   }
// }
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfarm/model/profile_model.dart';
import 'package:smartfarm/service/api_service.dart';
import 'package:smartfarm/view/login_view.dart';

class ProfileController extends GetxController {
  var farmer = Rxn<Farmer>();
  var isLoading = false.obs;

  final formKey = GlobalKey<FormState>();

  final firstNamecrl = TextEditingController();
  final lastNamecrl = TextEditingController();
  final phoneNumbercrl = TextEditingController();
  final emailcrl = TextEditingController();
  final aadharNumbercrl = TextEditingController();
  final houseNamecrl = TextEditingController();
  final villagecrl = TextEditingController();
  final districtcrl = TextEditingController();
  final statecrl = TextEditingController();
  final pincodecrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  @override
  void onClose() {
    firstNamecrl.dispose();
    lastNamecrl.dispose();
    phoneNumbercrl.dispose();
    emailcrl.dispose();
    aadharNumbercrl.dispose();
    houseNamecrl.dispose();
    villagecrl.dispose();
    districtcrl.dispose();
    statecrl.dispose();
    pincodecrl.dispose();
    super.onClose();
  }

  // Validation methods
  String? validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return '$fieldName should only contain letters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value.trim())) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  String? validateAadhar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Aadhar number is required';
    }
    if (!RegExp(r'^\d{12}$').hasMatch(value.trim())) {
      return 'Aadhar number must be 12 digits';
    }
    return null;
  }

  String? validatePincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pincode is required';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Pincode must be 6 digits';
    }
    return null;
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    return null;
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final profile = await ApiService.getFarmerProfile(token);
      farmer.value = profile;
      firstNamecrl.text = profile.firstName;
      lastNamecrl.text = profile.lastName;
      phoneNumbercrl.text = profile.phoneNumber;
      emailcrl.text = profile.email;
      aadharNumbercrl.text = profile.aadharNumber;
      houseNamecrl.text = profile.houseName;
      villagecrl.text = profile.village;
      districtcrl.text = profile.district;
      statecrl.text = profile.state;
      pincodecrl.text = profile.pincode;
    } catch (e) {
      log('message: $e');
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        "Validation Error",
        "Please fix all errors before submitting",
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      Farmer updated = Farmer(
        id: farmer.value!.id,
        username: farmer.value!.username,
        firstName: firstNamecrl.text.trim(),
        lastName: lastNamecrl.text.trim(),
        email: emailcrl.text.trim(),
        phoneNumber: phoneNumbercrl.text.trim(),
        aadharNumber: aadharNumbercrl.text.trim(),
        houseName: houseNamecrl.text.trim(),
        village: villagecrl.text.trim(),
        district: districtcrl.text.trim(),
        state: statecrl.text.trim(),
        pincode: pincodecrl.text.trim(),
      );

      final success = await ApiService.updateFarmerProfile(token, updated);
      if (success) {
        Get.snackbar(
          "Success",
          "Profile updated successfully",
          backgroundColor: const Color(0xFF4CAF50).withOpacity(0.9),
          colorText: Colors.white,
        );
        fetchProfile(); // Refresh the data
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      String message = await ApiService.logoutUser(token);
      await prefs.remove('token');
      Get.offAll(() => LoginPage());
      Get.snackbar("Success", message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      await prefs.remove('token');
      Get.offAll(() => LoginPage());
      Get.snackbar(
        "Logout Warning",
        "Logged out locally, but server logout failed",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }

    isLoading.value = false;
  }
}
