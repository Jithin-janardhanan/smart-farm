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
import 'package:smartfarm/view/curved_appbar.dart';
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
      appBar: CurvedAppBar(),
      
      body: Obx(() {
        if (farmController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          );
        }

        if (farmController.farms.isEmpty) {
  return RefreshIndicator(
    onRefresh: farmController.fetchFarms,
    color: Colors.green,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(), // <-- allows pull even if empty
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
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
          ),
        ),
      ],
    ),
  );
}

        return RefreshIndicator(
          onRefresh: farmController.fetchFarms,
          color: Colors.green,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: farmController.farms.length,
            itemBuilder: (context, index) {
              final farm = farmController.farms[index];
              return GestureDetector(
                onTap: () => navigateToMotors(farm.id),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with icon and emergency button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.agriculture,
                                color: Colors.green[600],
                                size: 20,
                              ),
                            ),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.power_settings_new,
                                  color: Colors.red[600],
                                  size: 16,
                                ),
                                tooltip: "Emergency Stop",
                                onPressed: () {
                                  _showEmergencyDialog(
                                    context,
                                    farm.farmName,
                                    () {
                                      farmController.triggerEmergencyStop(
                                        farm.id,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Farm name
                        Text(
                          farm.farmName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        // Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                farm.location,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Farm area
                        Row(
                          children: [
                            Icon(
                              Icons.landscape_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${farm.farmArea} acres',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Status indicator
                        Container(
                          width: double.infinity,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Active',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
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
