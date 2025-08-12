import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/model/colors_model.dart';
import '../controller/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isTablet = screenWidth > 600;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: AppColors.background, // Light gray-white background
      appBar: AppBar(
        title: Center(
          child: Text(
            'Farmer Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.white,
              fontSize: isTablet ? 22 : 18,
            ),
          ),
        ),
        backgroundColor: AppColors.primaryGreen, // Standard green
        elevation: 3,
        shadowColor: AppColors.primaryGreen.withOpacity(0.3),
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(context, controller),
            icon: const Icon(Icons.logout_rounded, color: AppColors.white),
            iconSize: isTablet ? 28 : 24,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.secondaryGreen,
                  strokeWidth: isTablet ? 4 : 3,
                ),
                SizedBox(height: isTablet ? 20 : 16),
                Text(
                  'Loading profile...',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32 : 16,
            vertical: isTablet ? 24 : 16,
          ),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header - Responsive
                _buildProfileHeader(context, controller, isTablet),

                SizedBox(height: isTablet ? 32 : 24),

                // Content Layout - Responsive
                if (isTablet && isLandscape)
                  _buildTabletLandscapeLayout(context, controller)
                else
                  _buildMobileLayout(context, controller, isTablet),

                SizedBox(height: isTablet ? 40 : 32),

                // Update Button - Responsive
                _buildUpdateButton(context, controller, isTablet),

                SizedBox(height: isTablet ? 32 : 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    ProfileController controller,
    bool isTablet,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryGreen,
            AppColors.secondaryGreen,
          ], // Standard green gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: isTablet ? 20 : 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(isTablet ? 70 : 60),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.agriculture_rounded,
              size: isTablet ? 70 : 55,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Obx(
            () => Text(
              controller.farmer.value?.username ?? 'Loading...',
              style: TextStyle(
                fontSize: isTablet ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                shadows: const [
                  Shadow(
                    color: AppColors.black,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 20 : 16,
              vertical: isTablet ? 10 : 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              '🌱 Smart Farmer',
              style: TextStyle(
                color: AppColors.white,
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLandscapeLayout(
    BuildContext context,
    ProfileController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildSectionTitle('👤 Personal Information', true),
              const SizedBox(height: 16),
              _buildPersonalInfoFields(controller, true),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            children: [
              _buildSectionTitle('🏠 Farm Address', true),
              const SizedBox(height: 16),
              _buildAddressFields(controller, true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    ProfileController controller,
    bool isTablet,
  ) {
    return Column(
      children: [
        _buildSectionTitle('👤 Personal Information', isTablet),
        SizedBox(height: isTablet ? 20 : 16),
        _buildPersonalInfoFields(controller, isTablet),
        SizedBox(height: isTablet ? 32 : 24),
        _buildSectionTitle('🏠 Farm Address', isTablet),
        SizedBox(height: isTablet ? 20 : 16),
        _buildAddressFields(controller, isTablet),
      ],
    );
  }

  Widget _buildPersonalInfoFields(ProfileController controller, bool isTablet) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.firstNamecrl,
                label: 'First Name',
                icon: Icons.person_outline_rounded,
                validator: (value) =>
                    controller.validateName(value, 'First name'),
                isTablet: isTablet,
              ),
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: _buildTextField(
                controller: controller.lastNamecrl,
                label: 'Last Name',
                icon: Icons.person_outline_rounded,
                validator: (value) =>
                    controller.validateName(value, 'Last name'),
                isTablet: isTablet,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 20 : 16),
        _buildTextField(
          controller: controller.emailcrl,
          label: 'Email Address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: controller.validateEmail,
          isTablet: isTablet,
        ),
        SizedBox(height: isTablet ? 20 : 16),
        _buildTextField(
          controller: controller.phoneNumbercrl,
          label: 'Phone Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: controller.validatePhoneNumber,
          isTablet: isTablet,
        ),
        SizedBox(height: isTablet ? 20 : 16),
        _buildTextField(
          controller: controller.aadharNumbercrl,
          label: 'Aadhar Number',
          icon: Icons.credit_card_outlined,
          keyboardType: TextInputType.number,
          validator: controller.validateAadhar,
          isTablet: isTablet,
        ),
      ],
    );
  }

  Widget _buildAddressFields(ProfileController controller, bool isTablet) {
    return Column(
      children: [
        _buildTextField(
          controller: controller.houseNamecrl,
          label: 'Farm House Name',
          icon: Icons.home_work_outlined,
          validator: (value) =>
              controller.validateRequired(value, 'House name'),
          isTablet: isTablet,
        ),
        SizedBox(height: isTablet ? 20 : 16),
        _buildTextField(
          controller: controller.villagecrl,
          label: 'Village/Town',
          icon: Icons.landscape_outlined,
          validator: (value) => controller.validateRequired(value, 'Village'),
          isTablet: isTablet,
        ),
        SizedBox(height: isTablet ? 20 : 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.districtcrl,
                label: 'District',
                icon: Icons.map_outlined,
                validator: (value) =>
                    controller.validateRequired(value, 'District'),
                isTablet: isTablet,
              ),
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: _buildTextField(
                controller: controller.statecrl,
                label: 'State',
                icon: Icons.public_outlined,
                validator: (value) =>
                    controller.validateRequired(value, 'State'),
                isTablet: isTablet,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 20 : 16),
        _buildTextField(
          controller: controller.pincodecrl,
          label: 'Pincode',
          icon: Icons.pin_drop_outlined,
          keyboardType: TextInputType.number,
          validator: controller.validatePincode,
          isTablet: isTablet,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 20,
        vertical: isTablet ? 14 : 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.secondaryGreen, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreen.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isTablet ? 20 : 17,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required bool isTablet,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          color: AppColors.black,
          fontSize: isTablet ? 18 : 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: AppColors.black,
            size: isTablet ? 26 : 22,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
            borderSide: const BorderSide(color: AppColors.lightGreen),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
            borderSide: const BorderSide(color: AppColors.black, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
            borderSide: const BorderSide(
              color: AppColors.primaryGreen,
              width: 2.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
            borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
            borderSide: const BorderSide(color: AppColors.errorRed, width: 2.5),
          ),
          filled: true,
          fillColor: AppColors.white,
          labelStyle: TextStyle(
            color: AppColors.secondaryGreen,
            fontSize: isTablet ? 17 : 15,
            fontWeight: FontWeight.w500,
          ),
          errorStyle: TextStyle(
            color: AppColors.errorRed,
            fontSize: isTablet ? 14 : 13,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: isTablet ? 17 : 15,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 20,
            vertical: isTablet ? 22 : 18,
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton(
    BuildContext context,
    ProfileController controller,
    bool isTablet,
  ) {
    return Container(
      width: double.infinity,
      height: isTablet ? 65 : 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _showUpdateConfirmation(context, controller),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco_rounded,
              color: AppColors.white,
              size: isTablet ? 26 : 22,
            ),
            SizedBox(width: isTablet ? 12 : 10),
            Text(
              'Update Farm Profile',
              style: TextStyle(
                fontSize: isTablet ? 20 : 17,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateConfirmation(
    BuildContext context,
    ProfileController controller,
  ) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.update_rounded,
                color: AppColors.secondaryGreen,
                size: isTablet ? 32 : 28,
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                'Update Profile',
                style: TextStyle(
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 22 : 20,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to update your farm profile with the current information?',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: isTablet ? 18 : 16,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: isTablet ? 12 : 8),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                ),
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.updateProfile();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 20,
                    vertical: isTablet ? 14 : 12,
                  ),
                ),
                child: Text(
                  'Update',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 18 : 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, ProfileController controller) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: AppColors.errorRed,
                size: isTablet ? 32 : 28,
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 22 : 20,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout from Smart Farm? You will need to login again to access your account.',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: isTablet ? 18 : 16,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: isTablet ? 12 : 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.errorRed,
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 20,
                    vertical: isTablet ? 14 : 12,
                  ),
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 18 : 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
