import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfarm/controller/farm_controller.dart';
import 'package:smartfarm/model/colors_model.dart';
import 'package:smartfarm/view/curved_appbar.dart';
import 'package:smartfarm/view/notificationlog.dart';
import 'package:smartfarm/view/profile.dart';
import 'package:smartfarm/view/tab_controller.dart';
import 'package:smartfarm/weather/weather_view.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  final String token;
  final FarmController farmController = Get.put(FarmController());

  HomePage({super.key, required this.token});

  Future<void> _launchPrivacyPolicy() async {
    final Uri url = Uri.parse(
      'https://www.freeprivacypolicy.com/live/51146187-bd61-4675-aff6-705c863a61f1',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchFeedback() async {
    final Uri url = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.agrita.app',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> navigateToMotors(BuildContext context, int farmId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      Get.to(() => IoTDashboardPage(farmId: farmId, token: token));
    } else {
      // FIX Bug 6: Show user-visible feedback instead of silent debugPrint
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expired. Please log in again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CurvedAppBar(),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.3,
      drawer: Drawer(
        backgroundColor: colorScheme.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/Agriculture.jpeg"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.3),
                    BlendMode.darken,
                  ),
                ),
                gradient: AppColors.primaryGradient,
              ),
              child: Center(
                child: Text(
                  "Agrita",
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.home_outlined,
              title: 'Home',
              colorScheme: colorScheme,
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              colorScheme: colorScheme,
              onTap: () {
                Navigator.pop(context);
                Get.to(() => NotificationPage());
              },
            ),
            _buildDrawerItem(
              icon: Icons.person_outline,
              title: 'Profile',
              colorScheme: colorScheme,
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const ProfileView());
              },
            ),
            _buildDrawerItem(
              icon: Icons.feedback_outlined,
              title: 'Feedback',
              colorScheme: colorScheme,
              onTap: _launchFeedback,
            ),
            _buildDrawerItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              colorScheme: colorScheme,
              onTap: _launchPrivacyPolicy,
            ),
          ],
        ),
      ),

      body: Obx(() {
        if (farmController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await farmController.fetchFarms();
            await farmController.fetchAllMotors();
          },
          color: colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryCard(
                        title: "Farms",
                        value: farmController.totalFarms.toString(),
                        icon: Icons.agriculture,
                        color: colorScheme.primary,
                        colorScheme: colorScheme,
                      ),
                      _buildSummaryCard(
                        title: "Motors",
                        value: farmController.totalMotors.toString(),
                        icon: Icons.settings_input_component,
                        color: Colors.blue,
                        colorScheme: colorScheme,
                      ),
                      _buildSummaryCard(
                        title: "Running",
                        value: farmController.runningMotors.toString(),
                        icon: Icons.power,
                        color: Colors.green,
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                WeatherForecastWidget(token: token),
                const SizedBox(height: 10),

                if (farmController.farms.isEmpty)
                  // FIX Bug 5: ListView inside Column with unbounded height
                  // caused "Vertical viewport was given unbounded height" error.
                  // Replaced with a plain Column-compatible layout.
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.agriculture_outlined,
                            size: 80,
                            color: colorScheme.secondary.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No farms found',
                            style: textTheme.bodyLarge?.copyWith(
                              fontSize: 18,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pull down to refresh',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: farmController.farms.length,
                    itemBuilder: (context, index) {
                      final farm = farmController.farms[index];
                      return GestureDetector(
                        // FIX Bug 6: pass context so SnackBar can be shown
                        onTap: () => navigateToMotors(context, farm.id),
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppColors.greenGlow,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: colorScheme.secondary.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Icon(
                                        Icons.agriculture,
                                        color: colorScheme.primary,
                                        size: 20,
                                      ),
                                    ),
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppColors.errorRed.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: Icon(
                                          Icons.power_settings_new,
                                          color: AppColors.errorRed,
                                          size: 16,
                                        ),
                                        tooltip: "Emergency Stop",
                                        onPressed: () {
                                          _showEmergencyDialog(
                                            context,
                                            farm.farmName,
                                            () => farmController
                                                .triggerEmergencyStop(farm.id),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  farm.farmName,
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: colorScheme.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: colorScheme.secondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        farm.location,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.7),
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.landscape_outlined,
                                      size: 14,
                                      color: colorScheme.secondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${farm.farmArea} acres',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurface.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  width: double.infinity,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Active',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // FIX Bug 7: Added `colorScheme` param so title text uses theme color
  // instead of hardcoded Colors.black87, which breaks in dark mode.
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ColorScheme colorScheme,
  }) {
    return Container(
      width: 103,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              // Was Colors.black87 — invisible in dark mode
              color: colorScheme.onSurface.withValues(alpha: 0.75),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showEmergencyDialog(
    BuildContext context,
    String farmName,
    VoidCallback onConfirm,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[600]),
              const SizedBox(width: 8),
              Text(
                'Emergency Stop',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to trigger emergency stop for $farmName?',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: colorScheme.secondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Stop'),
            ),
          ],
        );
      },
    );
  }
}
