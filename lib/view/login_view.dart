import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/login_controller.dart';
import 'package:smartfarm/model/colors_model.dart';

class LoginPage extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isLandscape = media.orientation == Orientation.landscape;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: height),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? width * 0.1 : 24,
                    vertical: (isTablet ? 40 : 20) + 60,
                  ),
                  child: Form(
                    key: controller.formKey,
                    child: Obx(
                      () => isTablet && isLandscape
                          ? _buildTabletLandscapeLayout(context, width)
                          : _buildMobileLayout(context, width),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔹 Tablet Landscape Layout
  Widget _buildTabletLandscapeLayout(BuildContext context, double width) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Center(child: _buildWelcomeSection(context, width * 0.5)),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 1,
          child: Center(child: _buildLoginForm(context, width * 0.5)),
        ),
      ],
    );
  }

  // 🔹 Mobile / Portrait Layout
  Widget _buildMobileLayout(BuildContext context, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: width * 0.15),
        _buildWelcomeSection(context, width),
        SizedBox(height: width * 0.12),
        _buildLoginForm(context, width),
        SizedBox(height: width * 0.08),
      ],
    );
  }

  // 🔹 Welcome Section
  Widget _buildWelcomeSection(BuildContext context, double width) {
    final isTablet = width > 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: isTablet ? 140 : 120,
          height: isTablet ? 140 : 120,
          child: Container(
            padding: EdgeInsets.all(isTablet ? 28 : 20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(100), // full circle
              boxShadow: AppColors.greenGlow,
            ),
            child: Image.asset(
              'assets/images/farmlogo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: isTablet ? 24 : 16),
        Text(
          "Agrita",
          style: TextStyle(
            fontSize: isTablet ? 36 : 28,
            fontWeight: FontWeight.bold,
            color: AppColors.lightAccent,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Text(
          "Smart Agriculture Platform",
          style: TextStyle(
            fontSize: isTablet ? 18 : 14,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 🔹 Login Form
  Widget _buildLoginForm(BuildContext context, double width) {
    final isTablet = width > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTextField(
          context: context,
          controller: controller.phoneController,
          label: 'Phone Number',
          icon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          validator: controller.validatePhone,
          isTablet: isTablet,
        ),
        SizedBox(height: isTablet ? 24 : 20),
        _buildTextField(
          context: context,
          controller: controller.passwordController,
          label: 'Password',
          icon: Icons.lock_rounded,
          isPassword: true,
          validator: controller.validatePassword,
          isTablet: isTablet,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            // onPressed: controller.forgotPassword,
            onPressed: () {},
            child: Text(
              "Forgot Password?",
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        SizedBox(height: isTablet ? 40 : 30),
        _buildLoginButton(context, isTablet),
      ],
    );
  }

  // 🔹 TextField Design
  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isPassword = false,
    required bool isTablet,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && !this.controller.isPasswordVisible.value,
      validator: validator,
      style: TextStyle(
        color: isDark ? AppColors.darkText : AppColors.lightText,
        fontSize: isTablet ? 18 : 16,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
          fontSize: isTablet ? 17 : 15,
        ),
        prefixIcon: Icon(icon, color: colorScheme.primary),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  this.controller.isPasswordVisible.value
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: colorScheme.secondary,
                ),
                onPressed: this.controller.togglePasswordVisibility,
              )
            : null,
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
          borderSide: BorderSide(color: colorScheme.secondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.black26,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorStyle: TextStyle(
          color: AppColors.errorRed,
          fontSize: isTablet ? 14 : 13,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 20,
          vertical: isTablet ? 20 : 16,
        ),
      ),
    );
  }

  // 🔹 Login Button
  Widget _buildLoginButton(BuildContext context, bool isTablet) {
    final colorScheme = Theme.of(context).colorScheme;

    return controller.isLoading.value
        ? CircularProgressIndicator(color: colorScheme.secondary)
        : SizedBox(
            width: double.infinity,
            height: isTablet ? 65 : 55,
            child: ElevatedButton(
              onPressed: controller.login,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
                ),
              ).copyWith(elevation: MaterialStateProperty.all(0)),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
                  boxShadow: AppColors.greenGlow,
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.login_rounded,
                        color: Colors.black,
                        size: isTablet ? 26 : 22,
                      ),
                      SizedBox(width: isTablet ? 12 : 10),
                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
