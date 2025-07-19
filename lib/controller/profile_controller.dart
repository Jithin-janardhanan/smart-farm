import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfarm/model/profile_model.dart';
import 'package:smartfarm/service/api_service.dart';

class profileController extends GetxController {
  var farmer = Rxn<Farmer>();
  var isLoading = false.obs;

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
    emailcrl.text = profile.email ;
    aadharNumbercrl.text = profile.aadharNumber;
    houseNamecrl.text = profile.houseName ;
    villagecrl.text = profile.village;
    districtcrl.text = profile.district;
    statecrl.text = profile.state ;
    pincodecrl.text = profile.pincode ;
      
    } catch (e) {
      log('message: $e');
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> updateProfile() async {
  isLoading.value = true;
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    Farmer updated = Farmer(
      id: farmer.value!.id,
      username: farmer.value!.username,
      firstName: firstNamecrl.text,
      lastName: lastNamecrl.text,
      email: emailcrl.text,
      phoneNumber: phoneNumbercrl.text,
      aadharNumber: aadharNumbercrl.text,
      houseName: houseNamecrl.text,
      village: villagecrl.text,
      district: districtcrl.text,
      state: statecrl.text,
      pincode: pincodecrl.text,
    );

    final success = await ApiService.updateFarmerProfile(token, updated);
    if (success) {
      Get.snackbar("Success", "Profile updated successfully");
      fetchProfile(); // Refresh the data
    }
  } catch (e) {
    Get.snackbar("Error", e.toString());
  } finally {
    isLoading.value = false;
  }
}

}
