import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isTablet = screenWidth > 600;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        elevation: 4,
        shadowColor: colorScheme.secondary.withOpacity(0.3),
        title: Center(
          child: Text(
            'Farmer Profile',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 24 : 20,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(context, controller),
            icon: Icon(Icons.logout_rounded, color: colorScheme.secondary),
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
                  color: colorScheme.primary,
                  strokeWidth: isTablet ? 4 : 3,
                ),
                const SizedBox(height: 18),
                Text(
                  'Loading profile...',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.7),
                    fontSize: isTablet ? 18 : 16,
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
              children: [
                SizedBox(height: isTablet ? 30 : 20),
                if (isTablet && isLandscape)
                  _buildTabletLayout(controller, context)
                else
                  _buildMobileLayout(controller, isTablet, context),

                SizedBox(height: isTablet ? 40 : 28),
                _buildUpdateButton(context, controller, isTablet),
              ],
            ),
          ),
        );
      }),
    );
  }

  // 🔹 Mobile Layout
  Widget _buildMobileLayout(
    ProfileController controller,
    bool isTablet,
    BuildContext context,
  ) {
    return Column(
      children: [
        _buildSectionTitle('Personal Info', isTablet, context),
        const SizedBox(height: 18),
        _buildPersonalFields(controller, isTablet, context),
        const SizedBox(height: 30),
        _buildSectionTitle('Farm Address', isTablet, context),
        const SizedBox(height: 18),
        _buildAddressFields(controller, isTablet, context),
      ],
    );
  }

  // 🔹 Tablet Layout
  Widget _buildTabletLayout(
    ProfileController controller,
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildSectionTitle('Personal Info', true, context),
              const SizedBox(height: 18),
              _buildPersonalFields(controller, true, context),
            ],
          ),
        ),
        const SizedBox(width: 28),
        Expanded(
          child: Column(
            children: [
              _buildSectionTitle('Farm Address', true, context),
              const SizedBox(height: 18),
              _buildAddressFields(controller, true, context),
            ],
          ),
        ),
      ],
    );
  }

  // 🔹 Text Field Builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required bool isTablet,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: theme.textTheme.bodyLarge?.copyWith(fontSize: isTablet ? 18 : 16),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: colorScheme.primary,
          size: isTablet ? 26 : 22,
        ),
        labelText: label,
        labelStyle: theme.inputDecorationTheme.labelStyle,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 22 : 18,
          vertical: isTablet ? 20 : 16,
        ),
      ),
    );
  }

  // 🔹 Section Title
  Widget _buildSectionTitle(String title, bool isTablet, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          Icons.arrow_right_rounded,
          color: colorScheme.primary,
          size: isTablet ? 30 : 26,
        ),
        Text(
          title,
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 20 : 18,
          ),
        ),
      ],
    );
  }

  // 🔹 Personal Info Fields
  Widget _buildPersonalFields(
    ProfileController c,
    bool isTablet,
    BuildContext context,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: c.firstNamecrl,
                label: 'First Name',
                icon: Icons.person,
                validator: (v) => c.validateName(v, 'First name'),
                isTablet: isTablet,
                context: context,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: c.lastNamecrl,
                label: 'Last Name',
                icon: Icons.person,
                validator: (v) => c.validateName(v, 'Last name'),
                isTablet: isTablet,
                context: context,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _buildTextField(
          controller: c.emailcrl,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: c.validateEmail,
          isTablet: isTablet,
          context: context,
        ),
        const SizedBox(height: 18),
        _buildTextField(
          controller: c.phoneNumbercrl,
          label: 'Phone',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: c.validatePhoneNumber,
          isTablet: isTablet,
          context: context,
        ),
      ],
    );
  }

  // 🔹 Address Fields
  Widget _buildAddressFields(
    ProfileController c,
    bool isTablet,
    BuildContext context,
  ) {
    return Column(
      children: [
        _buildTextField(
          controller: c.houseNamecrl,
          label: 'Farm House',
          icon: Icons.home_outlined,
          validator: (v) => c.validateRequired(v, 'House name'),
          isTablet: isTablet,
          context: context,
        ),
        const SizedBox(height: 18),
        _buildTextField(
          controller: c.villagecrl,
          label: 'Village',
          icon: Icons.landscape_outlined,
          validator: (v) => c.validateRequired(v, 'Village'),
          isTablet: isTablet,
          context: context,
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: c.districtcrl,
                label: 'District',
                icon: Icons.map_outlined,
                validator: (v) => c.validateRequired(v, 'District'),
                isTablet: isTablet,
                context: context,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: c.statecrl,
                label: 'State',
                icon: Icons.public_outlined,
                validator: (v) => c.validateRequired(v, 'State'),
                isTablet: isTablet,
                context: context,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 🔹 Update Button
  Widget _buildUpdateButton(
    BuildContext context,
    ProfileController controller,
    bool isTablet,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      width: double.infinity,
      height: isTablet ? 60 : 52,
      child: ElevatedButton(
        onPressed: () => controller.updateProfile(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco_rounded,
              color: colorScheme.onPrimary,
              size: isTablet ? 26 : 22,
            ),
            const SizedBox(width: 10),
            Text(
              'Update Profile',
              style: TextStyle(
                fontSize: isTablet ? 20 : 17,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Logout Dialog
  void _showLogoutDialog(BuildContext context, ProfileController controller) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: colorScheme.error),
            const SizedBox(width: 8),
            Text('Logout', style: TextStyle(color: colorScheme.onSurface)),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.secondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.logout();
            },
            child: Text('Logout', style: TextStyle(color: colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
