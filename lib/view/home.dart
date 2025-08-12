// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:smartfarm/controller/farm_controller.dart';
// import 'package:smartfarm/view/profile.dart';
// import 'package:smartfarm/view/tab_controller.dart';

// class HomePage extends StatelessWidget {
//   final String token;

//   FarmController farmController = Get.put(FarmController());

//   HomePage({super.key, required this.token});

//   Future<void> navigateToMotors(int farmId) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token');

//     if (token != null) {
//       Get.to(() => IoTDashboardPage(farmId: farmId, token: token));
//     } else {
//       print("Token not found");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text('Smart farm'),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: IconButton(
//               onPressed: () => Get.to(ProfileView()),
//               icon: Icon(Icons.person),
//             ),
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (farmController.isLoading.value) {
//           return Center(child: CircularProgressIndicator());
//         }

//         return RefreshIndicator(
//           onRefresh: farmController.fetchFarms,
//           child: ListView.builder(
//             itemCount: farmController.farms.length,
//             itemBuilder: (context, index) {
//               final farm = farmController.farms[index];
//               return Card(
//                 margin: EdgeInsets.all(10),
//                 child: ListTile(
//                   onTap: () {
//                     navigateToMotors(farm.id);
//                   },
//                   title: Text(
//                     farm.farmName,
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("📍 ${farm.location}"),
//                       Text("Area: ${farm.farmArea} acres"),
//                       Text("GSM: ${farm.gsmNumber}"),
//                     ],
//                   ),
//                   trailing: IconButton(
//                     icon: Icon(Icons.warning, color: Colors.red),
//                     tooltip: "Emergency Stop",
//                     onPressed: () {
//                       farmController.triggerEmergencyStop(farm.id);
//                     },
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       }),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfarm/controller/farm_controller.dart';
import 'package:smartfarm/view/profile.dart';
import 'package:smartfarm/view/tab_controller.dart';

class HomePage extends StatelessWidget {
  final String token;
  final FarmController farmController = Get.put(FarmController());

  HomePage({super.key, required this.token});

  Future<void> navigateToMotors(int farmId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      Get.to(() => IoTDashboardPage(farmId: farmId, token: token));
    } else {
      print("Token not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Smart Farm',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => ProfileView()),
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: Obx(() {
        if (farmController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          );
        }

        if (farmController.farms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.agriculture_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No farms found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pull down to refresh',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: farmController.fetchFarms,
          color: Colors.green,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: farmController.farms.length,
            itemBuilder: (context, index) {
              final farm = farmController.farms[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  onTap: () => navigateToMotors(farm.id),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      Icons.agriculture,
                      color: Colors.green[600],
                      size: 24,
                    ),
                  ),
                  title: Text(
                    farm.farmName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                farm.location,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.landscape_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${farm.farmArea} acres',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.power_settings_new,
                        color: Colors.red[600],
                        size: 20,
                      ),
                      tooltip: "Emergency Stop",
                      onPressed: () {
                        _showEmergencyDialog(context, farm.farmName, () {
                          farmController.triggerEmergencyStop(farm.id);
                        });
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _showEmergencyDialog(
    BuildContext context,
    String farmName,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[600]),
              const SizedBox(width: 8),
              const Text('Emergency Stop'),
            ],
          ),
          content: Text(
            'Are you sure you want to trigger emergency stop for $farmName?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Stop'),
            ),
          ],
        );
      },
    );
  }
}
