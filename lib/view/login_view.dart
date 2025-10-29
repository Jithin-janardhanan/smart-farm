import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/login_controller.dart';

class LoginPage extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isLandscape = media.orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
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
                    vertical: isTablet ? 40 : 20,
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
          child: Center(child: _buildWelcomeSection(width * 0.5)),
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
        _buildWelcomeSection(width),
        SizedBox(height: width * 0.12),
        _buildLoginForm(context, width),
        SizedBox(height: width * 0.08),
      ],
    );
  }

  // 🔹 Welcome Section
  Widget _buildWelcomeSection(double width) {
    final isTablet = width > 600;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 28 : 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00FF88), Color(0xFF00C853)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isTablet ? 70 : 60),
            boxShadow: [
              BoxShadow(
                color: Colors.greenAccent.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/farmlogo.png', 
            height: isTablet ? 100 : 80,
            fit: BoxFit.contain,
          ),
        ),

        SizedBox(height: isTablet ? 24 : 16),
        Text(
          "Agrita",
          style: TextStyle(
            fontSize: isTablet ? 36 : 28,
            fontWeight: FontWeight.bold,
            color: Colors.greenAccent,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Text(
          "Smart Agriculture Platform",
          style: TextStyle(fontSize: isTablet ? 18 : 14, color: Colors.white70),
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
          controller: controller.phoneController,
          label: 'Phone Number',
          icon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          validator: controller.validatePhone,
          isTablet: isTablet,
        ),
        SizedBox(height: isTablet ? 24 : 20),
        _buildTextField(
          controller: controller.passwordController,
          label: 'Password',
          icon: Icons.lock_rounded,
          isPassword: true,
          validator: controller.validatePassword,
          isTablet: isTablet,
        ),
        SizedBox(height: isTablet ? 40 : 30),
        _buildLoginButton(isTablet),
      ],
    );
  }

  // 🔹 TextField Design
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isPassword = false,
    required bool isTablet,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && !this.controller.isPasswordVisible.value,
      validator: validator,
      style: TextStyle(
        color: Colors.white,
        fontSize: isTablet ? 18 : 16,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white70,
          fontSize: isTablet ? 17 : 15,
        ),
        prefixIcon: Icon(icon, color: Colors.greenAccent),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  this.controller.isPasswordVisible.value
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: Colors.greenAccent,
                ),
                onPressed: this.controller.togglePasswordVisibility,
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
          borderSide: const BorderSide(color: Colors.greenAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 18 : 15),
          borderSide: const BorderSide(color: Colors.greenAccent, width: 2),
        ),
        errorStyle: TextStyle(
          color: Colors.redAccent,
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
  Widget _buildLoginButton(bool isTablet) {
    return controller.isLoading.value
        ? const CircularProgressIndicator(color: Colors.greenAccent)
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C853), Color(0xFF00FF88)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
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
