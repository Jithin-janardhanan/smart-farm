// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:smartfarm/controller/login_controller.dart';

// class LoginPage extends StatelessWidget {
//   final LoginController controller = Get.put(LoginController());

//   LoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Farmer Login")),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Obx(
//           () => Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextField(
//                 controller: controller.phoneController,
//                 keyboardType: TextInputType.phone,
//                 decoration: InputDecoration(labelText: 'Phone Number'),
//               ),
//               TextField(
//                 controller: controller.passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(labelText: 'Password'),
//               ),
//               SizedBox(height: 20),
//               controller.isLoading.value
//                   ? Center(child: CircularProgressIndicator())
//                   : SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: controller.login,
//                         child: Text("Login"),
//                       ),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/login_controller.dart';

class LoginPage extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isTablet = screenWidth > 600;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light background
      appBar: AppBar(
        title: Text(
          "Farmer Login",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 22 : 18,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32), // Standard green
        elevation: 3,
        shadowColor: const Color(0xFF2E7D32).withOpacity(0.3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: isLandscape
              ? screenHeight - kToolbarHeight - mediaQuery.padding.top
              : null,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFFF8F9FA), Colors.green.shade50],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 40 : 20,
              vertical: isTablet ? 30 : 20,
            ),
            child: Form(
              key: controller.formKey,
              child: Obx(
                () => isLandscape && isTablet
                    ? _buildTabletLandscapeLayout(context, isTablet)
                    : _buildMobileLayout(context, isTablet),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLandscapeLayout(BuildContext context, bool isTablet) {
    return Row(
      children: [
        // Left side - Welcome section
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_buildWelcomeSection(isTablet)],
          ),
        ),
        const SizedBox(width: 40),
        // Right side - Form section
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_buildLoginForm(context, isTablet)],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: isTablet ? 50 : 40),
        _buildWelcomeSection(isTablet),
        SizedBox(height: isTablet ? 60 : 50),
        _buildLoginForm(context, isTablet),
        SizedBox(height: isTablet ? 30 : 20),
      ],
    );
  }

  Widget _buildWelcomeSection(bool isTablet) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(isTablet ? 70 : 60),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.agriculture_rounded,
              size: isTablet ? 90 : 80,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            "Welcome Back!",
            style: TextStyle(
              fontSize: isTablet ? 32 : 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B5E20),
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            "Sign in to continue to SmartFarm",
            style: TextStyle(
              fontSize: isTablet ? 20 : 16,
              color: const Color(0xFF2E7D32),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 20 : 16,
              vertical: isTablet ? 10 : 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: const Color(0xFF4CAF50).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              "🌱 Smart Agriculture Platform",
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, bool isTablet) {
    return Column(
      children: [
        // Phone Number Field
        _buildTextField(
          controller: controller.phoneController,
          label: 'Phone Number',
          icon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          validator: controller.validatePhone,
          isTablet: isTablet,
        ),

        SizedBox(height: isTablet ? 24 : 20),

        // Password Field
        _buildTextField(
          controller: controller.passwordController,
          label: 'Password',
          icon: Icons.lock_rounded,
          isPassword: true,
          validator: controller.validatePassword,
          isTablet: isTablet,
        ),

        SizedBox(height: isTablet ? 40 : 30),

        // Login Button
        _buildLoginButton(isTablet),

        SizedBox(height: isTablet ? 30 : 20),

        // Forgot Password
        _buildForgotPassword(isTablet),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isPassword = false,
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
        obscureText: isPassword && !this.controller.isPasswordVisible.value,
        validator: validator,
        style: TextStyle(
          color: const Color(0xFF1B5E20),
          fontSize: isTablet ? 18 : 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: const Color(0xFF4CAF50),
            fontSize: isTablet ? 17 : 15,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF4CAF50),
            size: isTablet ? 26 : 22,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    this.controller.isPasswordVisible.value
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: const Color(0xFF4CAF50),
                    size: isTablet ? 26 : 22,
                  ),
                  onPressed: this.controller.togglePasswordVisibility,
                )
              : null,
          filled: true,
          fillColor: Colors.white,
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
          errorStyle: TextStyle(
            color: const Color(0xFFD32F2F),
            fontSize: isTablet ? 14 : 13,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 20,
            vertical: isTablet ? 22 : 18,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(bool isTablet) {
    return controller.isLoading.value
        ? Center(
            child: Container(
              width: isTablet ? 80 : 60,
              height: isTablet ? 80 : 60,
              padding: EdgeInsets.all(isTablet ? 20 : 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isTablet ? 40 : 30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF2E7D32),
                ),
                strokeWidth: isTablet ? 4 : 3,
              ),
            ),
          )
        : Container(
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
              onPressed: controller.login,
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
                    Icons.login_rounded,
                    color: Colors.white,
                    size: isTablet ? 26 : 22,
                  ),
                  SizedBox(width: isTablet ? 12 : 10),
                  Text(
                    "Login to SmartFarm",
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildForgotPassword(bool isTablet) {
    return Center(
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
        child: TextButton(
          onPressed: () {
            // Add forgot password functionality if needed
            Get.snackbar(
              "Info",
              "Contact your administrator for password reset",
              backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
              colorText: const Color(0xFF2E7D32),
              icon: const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF4CAF50),
              ),
            );
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 20,
              vertical: isTablet ? 16 : 12,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.help_outline_rounded,
                color: const Color(0xFF2E7D32),
                size: isTablet ? 22 : 20,
              ),
              SizedBox(width: isTablet ? 8 : 6),
              Text(
                "Forgot Password?",
                style: TextStyle(
                  color: const Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 18 : 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
