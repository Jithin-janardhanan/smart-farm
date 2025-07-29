import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfarm/view/login_view.dart';
import '../controller/profile_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isTablet = screenWidth > 600;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light gray-white background
      appBar: AppBar(
        title: Text(
          'Farmer Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: isTablet ? 22 : 18,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32), // Standard green
        elevation: 3,
        shadowColor: const Color(0xFF2E7D32).withOpacity(0.3),
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(context, controller),
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
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
                  color: const Color(0xFF4CAF50),
                  strokeWidth: isTablet ? 4 : 3,
                ),
                SizedBox(height: isTablet ? 20 : 16),
                Text(
                  'Loading profile...',
                  style: TextStyle(
                    color: const Color(0xFF2E7D32),
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
            Color(0xFF2E7D32),
            Color(0xFF4CAF50),
          ], // Standard green gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(isTablet ? 70 : 60),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.agriculture_rounded,
              size: isTablet ? 70 : 55,
              color: const Color(0xFF2E7D32),
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Obx(
            () => Text(
              controller.farmer.value?.username ?? 'Loading...',
              style: TextStyle(
                fontSize: isTablet ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    color: Colors.black26,
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
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              '🌱 Smart Farmer',
              style: TextStyle(
                color: Colors.white,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.15),
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
          color: const Color(0xFF2E7D32),
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
            color: const Color(0xFF2E7D32).withOpacity(0.1),
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
          color: const Color(0xFF1B5E20),
          fontSize: isTablet ? 18 : 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF4CAF50),
            size: isTablet ? 26 : 22,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
            borderSide: const BorderSide(color: Color(0xFF81C784)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
            borderSide: const BorderSide(color: Color(0xFF81C784), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
            borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
            borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2.5),
          ),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(
            color: const Color(0xFF4CAF50),
            fontSize: isTablet ? 17 : 15,
            fontWeight: FontWeight.w500,
          ),
          errorStyle: TextStyle(
            color: const Color(0xFFD32F2F),
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
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.4),
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
              color: Colors.white,
              size: isTablet ? 26 : 22,
            ),
            SizedBox(width: isTablet ? 12 : 10),
            Text(
              'Update Farm Profile',
              style: TextStyle(
                fontSize: isTablet ? 20 : 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.update_rounded,
                color: const Color(0xFF4CAF50),
                size: isTablet ? 32 : 28,
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                'Update Profile',
                style: TextStyle(
                  color: const Color(0xFF1B5E20),
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 22 : 20,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to update your farm profile with the current information?',
            style: TextStyle(
              color: const Color(0xFF424242),
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
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
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
                    color: Colors.white,
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: const Color(0xFFD32F2F),
                size: isTablet ? 32 : 28,
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                'Logout',
                style: TextStyle(
                  color: const Color(0xFF1B5E20),
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 22 : 20,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout from Smart Farm? You will need to login again to access your account.',
            style: TextStyle(
              color: const Color(0xFF424242),
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
                color: const Color(0xFFD32F2F),
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
                    color: Colors.white,
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
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:smartfarm/controller/profile_controller.dart';

// class ProfileView extends StatelessWidget {
//   const ProfileView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(ProfileController());

//     return Scaffold(
//       backgroundColor: Colors.grey.shade50, // Light background
//       appBar: AppBar(
//         title: const Text(
//           'Farmer Profile',
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         backgroundColor: const Color(0xFF4CAF50), // Fresh green
//         elevation: 2,
//         actions: [
//           IconButton(
//             onPressed: () => _showLogoutDialog(context, controller),
//             icon: const Icon(Icons.logout, color: Colors.white),
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return Center(
//             child: CircularProgressIndicator(
//               color: const Color(0xFF4CAF50), // Bright green loading
//             ),
//           );
//         }

//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: controller.formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Profile Header with Fresh Green Theme
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(25),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [
//                         Color(0xFF66BB6A),
//                         Color(0xFF4CAF50),
//                       ], // Fresh green gradient
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFF4CAF50).withOpacity(0.3),
//                         blurRadius: 15,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(60),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 10,
//                               offset: const Offset(0, 5),
//                             ),
//                           ],
//                         ),
//                         child: const Icon(
//                           Icons.agriculture,
//                           size: 55,
//                           color: Color(0xFF4CAF50),
//                         ),
//                       ),
//                       const SizedBox(height: 18),
//                       Obx(
//                         () => Text(
//                           controller.farmer.value?.username ?? 'Loading...',
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                             shadows: [
//                               Shadow(
//                                 color: Colors.black26,
//                                 offset: Offset(0, 2),
//                                 blurRadius: 4,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.25),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const Text(
//                           '🌱 Smart Farmer',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // Personal Information Section
//                 _buildSectionTitle('👤 Personal Information'),
//                 const SizedBox(height: 10),

//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildTextField(
//                         controller: controller.firstNamecrl,
//                         label: 'First Name',
//                         icon: Icons.person_outline,
//                         validator: (value) =>
//                             controller.validateName(value, 'First name'),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: _buildTextField(
//                         controller: controller.lastNamecrl,
//                         label: 'Last Name',
//                         icon: Icons.person_outline,
//                         validator: (value) =>
//                             controller.validateName(value, 'Last name'),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 15),

//                 _buildTextField(
//                   controller: controller.emailcrl,
//                   label: 'Email',
//                   icon: Icons.email_outlined,
//                   keyboardType: TextInputType.emailAddress,
//                   validator: controller.validateEmail,
//                 ),

//                 const SizedBox(height: 15),

//                 _buildTextField(
//                   controller: controller.phoneNumbercrl,
//                   label: 'Phone Number',
//                   icon: Icons.phone_outlined,
//                   keyboardType: TextInputType.phone,
//                   validator: controller.validatePhoneNumber,
//                 ),

//                 const SizedBox(height: 15),

//                 _buildTextField(
//                   controller: controller.aadharNumbercrl,
//                   label: 'Aadhar Number',
//                   icon: Icons.credit_card_outlined,
//                   keyboardType: TextInputType.number,
//                   validator: controller.validateAadhar,
//                 ),

//                 const SizedBox(height: 20),

//                 // Address Information Section
//                 _buildSectionTitle('🏠 Farm Address'),
//                 const SizedBox(height: 10),

//                 _buildTextField(
//                   controller: controller.houseNamecrl,
//                   label: 'Farm House Name',
//                   icon: Icons.home_work_outlined, // Farm house icon
//                   validator: (value) =>
//                       controller.validateRequired(value, 'House name'),
//                 ),

//                 const SizedBox(height: 15),

//                 _buildTextField(
//                   controller: controller.villagecrl,
//                   label: 'Village/Town',
//                   icon: Icons.landscape_outlined, // Rural landscape icon
//                   validator: (value) =>
//                       controller.validateRequired(value, 'Village'),
//                 ),

//                 const SizedBox(height: 15),

//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildTextField(
//                         controller: controller.districtcrl,
//                         label: 'District',
//                         icon: Icons.map_outlined,
//                         validator: (value) =>
//                             controller.validateRequired(value, 'District'),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: _buildTextField(
//                         controller: controller.statecrl,
//                         label: 'State',
//                         icon: Icons.public_outlined,
//                         validator: (value) =>
//                             controller.validateRequired(value, 'State'),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 15),

//                 _buildTextField(
//                   controller: controller.pincodecrl,
//                   label: 'Pincode',
//                   icon: Icons.pin_drop_outlined,
//                   keyboardType: TextInputType.number,
//                   validator: controller.validatePincode,
//                 ),

//                 const SizedBox(height: 30),

//                 // Update Button with Fresh Green Theme
//                 Container(
//                   width: double.infinity,
//                   height: 55,
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [
//                         Color(0xFF66BB6A),
//                         Color(0xFF4CAF50),
//                       ], // Fresh green gradient
//                       begin: Alignment.centerLeft,
//                       end: Alignment.centerRight,
//                     ),
//                     borderRadius: BorderRadius.circular(15),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFF4CAF50).withOpacity(0.4),
//                         blurRadius: 12,
//                         offset: const Offset(0, 6),
//                       ),
//                     ],
//                   ),
//                   child: ElevatedButton(
//                     onPressed: controller.updateProfile,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.transparent,
//                       shadowColor: Colors.transparent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: const [
//                         Icon(Icons.eco, color: Colors.white, size: 22),
//                         SizedBox(width: 10),
//                         Text(
//                           'Update Farm Profile',
//                           style: TextStyle(
//                             fontSize: 17,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(25),
//         border: Border.all(
//           color: const Color(0xFF4CAF50).withOpacity(0.5),
//           width: 2,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF4CAF50).withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 17,
//           fontWeight: FontWeight.bold,
//           color: Color(0xFF4CAF50),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF4CAF50).withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         validator: validator,
//         style: const TextStyle(
//           color: Color(0xFF2E7D32),
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//         ),
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(icon, color: const Color(0xFF4CAF50), size: 22),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: const BorderSide(color: Color(0xFF81C784)),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: const BorderSide(color: Color(0xFF81C784), width: 1.5),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2.5),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
//           ),
//           focusedErrorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: const BorderSide(color: Colors.redAccent, width: 2.5),
//           ),
//           filled: true,
//           fillColor: Colors.white,
//           labelStyle: const TextStyle(
//             color: Color(0xFF66BB6A),
//             fontSize: 15,
//             fontWeight: FontWeight.w500,
//           ),
//           errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 13),
//           hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 18,
//           ),
//         ),
//       ),
//     );
//   }

//   void _showLogoutDialog(BuildContext context, ProfileController controller) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           title: Row(
//             children: const [
//               Icon(Icons.logout, color: Color(0xFF4CAF50), size: 28),
//               SizedBox(width: 12),
//               Text(
//                 'Logout',
//                 style: TextStyle(
//                   color: Color(0xFF2E7D32),
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           content: const Text(
//             'Are you sure you want to logout from Smart Farm?',
//             style: TextStyle(color: Color(0xFF424242), fontSize: 16),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(color: Colors.grey, fontSize: 16),
//               ),
//             ),
//             Container(
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   controller.logout();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.transparent,
//                   shadowColor: Colors.transparent,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   'Logout',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
