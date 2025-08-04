import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/motorlist_controller.dart';
import 'package:smartfarm/view/valve_grouping.dart';

// class MotorListPage extends StatelessWidget {
//   final int farmId;
//   final String token; // Pass token from login

//   MotorListPage({super.key, required this.farmId, required this.token});

//   final MotorController controller = Get.put(MotorController());

//   @override
//   Widget build(BuildContext context) {
//     controller.fetchMotorsAndValves(farmId, token);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Motors & Valves'),
//         actions: [
//           ElevatedButton(
//             onPressed: () {
//               Get.to(() => ValveGroupPage(farmId: farmId, token: token));
//             },
//             child: Text("Go to Valve Grouping"),
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return Center(child: CircularProgressIndicator());
//         }

//         return SingleChildScrollView(
//           padding: EdgeInsets.all(12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "In Motors",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               ...controller.inMotors.map(
//                 (motor) => Card(
//                   child: ListTile(
//                     title: Text(motor.name),
//                     subtitle: Text(
//                       'Lora: ${motor.loraId}, Status: ${motor.status}',
//                     ),
//                     trailing: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: motor.status == "ON"
//                             ? Colors.red
//                             : Colors.green,
//                       ),
//                       onPressed: () {
//                         final newStatus = motor.status == "ON" ? "OFF" : "ON";
//                         controller.toggleMotor(
//                           motorId: motor.id,
//                           status: newStatus,
//                           farmId: farmId,
//                           token: token,
//                         );
//                       },
//                       child: Text(
//                         motor.status == "ON" ? "Turn OFF" : "Turn ON",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               SizedBox(height: 16),
//               Text(
//                 "Out Motors",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               ...controller.outMotors.map(
//                 (motor) => Card(
//                   child: ListTile(
//                     title: Text(motor.name),
//                     subtitle: Text(
//                       'Lora: ${motor.loraId}, Status: ${motor.status}',
//                     ),
//                     trailing: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: motor.status == "ON"
//                             ? Colors.red
//                             : Colors.green,
//                       ),
//                       onPressed: () {
//                         final newStatus = motor.status == "ON" ? "OFF" : "ON";
//                         controller.toggleMotor(
//                           motorId: motor.id,
//                           status: newStatus,
//                           farmId: farmId,
//                           token: token,
//                         );
//                       },
//                       child: Text(
//                         motor.status == "ON" ? "Turn OFF" : "Turn ON",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               SizedBox(height: 16),
//               Text(
//                 "Valve Groups",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),

//               Obx(() {
//                 return Column(
//                   children: controller.groupedValves.map((group) {
//                     return Card(
//                       margin: EdgeInsets.symmetric(vertical: 6),
//                       child: ExpansionTile(
//                         title: Text(group.name),
//                         subtitle: Text("Group ID: ${group.id}"),
//                         trailing: Obx(() {
//                           return Switch(
//                             value:
//                                 controller.groupToggleStates[group.id]?.value ??
//                                 false,
//                             onChanged: (_) {
//                               controller.toggleValveGroup(
//                                 groupId: group.id,
//                                 token: token,
//                                 farmId: farmId,
//                               );
//                             },
//                             activeColor: Colors.green,
//                             inactiveThumbColor: Colors.red,
//                           );
//                         }),

//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 8,
//                             ),
//                             child: LayoutBuilder(
//                               builder: (context, constraints) {
//                                 final screenWidth = MediaQuery.of(
//                                   context,
//                                 ).size.width;
//                                 final crossAxisCount = screenWidth < 600
//                                     ? 2
//                                     : 3;

//                                 return SizedBox(
//                                   height:
//                                       ((group.valves.length / crossAxisCount)
//                                           .ceil()) *
//                                       140,
//                                   child: SizedBox(
//                                     height: 350, // Adjust based on your needs
//                                     child: GridView.builder(
//                                       physics: NeverScrollableScrollPhysics(),
//                                       gridDelegate:
//                                           SliverGridDelegateWithFixedCrossAxisCount(
//                                             crossAxisCount: crossAxisCount,
//                                             mainAxisSpacing: 12,
//                                             crossAxisSpacing: 12,
//                                             childAspectRatio:
//                                                 1.3, // Reduced from 2.8
//                                           ),
//                                       itemCount: group.valves.length,
//                                       itemBuilder: (context, index) {
//                                         final valve = group.valves[index];
//                                         return Container(
//                                           padding: EdgeInsets.all(8),
//                                           decoration: BoxDecoration(
//                                             border: Border.all(
//                                               color: Colors.grey.shade300,
//                                             ),
//                                             borderRadius: BorderRadius.circular(
//                                               12,
//                                             ),
//                                             color: Colors.white,
//                                             boxShadow: [
//                                               BoxShadow(
//                                                 color: Colors.black12,
//                                                 blurRadius: 4,
//                                                 offset: Offset(0, 2),
//                                               ),
//                                             ],
//                                           ),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 valve.name,
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                                 maxLines: 1,
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                               SizedBox(height: 4),
//                                               Text(
//                                                 'Lora: ${valve.loraId}',
//                                                 style: TextStyle(fontSize: 12),
//                                                 maxLines: 1,
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                               SizedBox(height: 5),
//                                               Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   Text(
//                                                     valve.status == "ON"
//                                                         ? "Opened"
//                                                         : "Closed",
//                                                     style: TextStyle(
//                                                       color:
//                                                           valve.status == "ON"
//                                                           ? Colors.green
//                                                           : Colors.red,
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                     ),
//                                                   ),

//                                                   IconButton(
//                                                     icon: Icon(
//                                                       valve.status == "ON"
//                                                           ? Icons.toggle_on
//                                                           : Icons.toggle_off,
//                                                       color:
//                                                           valve.status == "ON"
//                                                           ? Colors.green
//                                                           : Colors.grey,
//                                                       size: 45,
//                                                     ),
//                                                     onPressed: () {
//                                                       final newStatus =
//                                                           valve.status == "ON"
//                                                           ? "OFF"
//                                                           : "ON";
//                                                       controller.toggleValve(
//                                                         valveId: valve.id,
//                                                         status: newStatus,
//                                                         token: token,
//                                                         farmId: farmId,
//                                                       );
//                                                     },
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 );
//               }),
//               SizedBox(height: 16),
//               Text(
//                 "Ungrouped Valves",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),

//               Obx(() {
//                 if (controller.ungroupedValves.isEmpty) {
//                   return Text("No ungrouped valves found.");
//                 }

//                 return Wrap(
//                   spacing: 12,
//                   runSpacing: 12,
//                   children: controller.ungroupedValves.map((valve) {
//                     return Container(
//                       width: MediaQuery.of(context).size.width / 2 - 24,
//                       padding: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(12),
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 4,
//                             offset: Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             valve.name,
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             'Lora: ${valve.loraId}',
//                             style: TextStyle(fontSize: 12),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           SizedBox(height: 1),

//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 valve.status == "ON" ? "Opened" : "Closed",
//                                 style: TextStyle(
//                                   color: valve.status == "ON"
//                                       ? Colors.green
//                                       : Colors.red,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               Align(
//                                 alignment: Alignment.centerRight,
//                                 child: IconButton(
//                                   icon: Icon(
//                                     valve.status == "ON"
//                                         ? Icons.toggle_on
//                                         : Icons.toggle_off,
//                                     color: valve.status == "ON"
//                                         ? Colors.green
//                                         : Colors.grey,
//                                     size: 50,
//                                   ),
//                                   onPressed: () {
//                                     final newStatus = valve.status == "ON"
//                                         ? "OFF"
//                                         : "ON";
//                                     controller.toggleValve(
//                                       valveId: valve.id,
//                                       status: newStatus,
//                                       token: token,
//                                       farmId: farmId,
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 );
//               }),
//             ],
//           ),
//         );
//       }),
//     );
//   }
// }

class MotorListTab extends StatelessWidget {
  final int farmId;
  final String token;

  MotorListTab({super.key, required this.farmId, required this.token});

  final MotorController controller = Get.find<MotorController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "In Motors",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...controller.inMotors.map(
              (motor) => Card(
                child: ListTile(
                  title: Text(motor.name),
                  subtitle: Text(
                    'Lora: ${motor.loraId}, Status: ${motor.status}',
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: motor.status == "ON"
                          ? Colors.red
                          : Colors.green,
                    ),
                    onPressed: () {
                      final newStatus = motor.status == "ON" ? "OFF" : "ON";
                      controller.toggleMotor(
                        motorId: motor.id,
                        status: newStatus,
                        farmId: farmId,
                        token: token,
                      );
                    },
                    child: Text(
                      motor.status == "ON" ? "Turn OFF" : "Turn ON",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),
            Text(
              "Out Motors",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...controller.outMotors.map(
              (motor) => Card(
                child: ListTile(
                  title: Text(motor.name),
                  subtitle: Text(
                    'Lora: ${motor.loraId}, Status: ${motor.status}',
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: motor.status == "ON"
                          ? Colors.red
                          : Colors.green,
                    ),
                    onPressed: () {
                      final newStatus = motor.status == "ON" ? "OFF" : "ON";
                      controller.toggleMotor(
                        motorId: motor.id,
                        status: newStatus,
                        farmId: farmId,
                        token: token,
                      );
                    },
                    child: Text(
                      motor.status == "ON" ? "Turn OFF" : "Turn ON",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),
            Text(
              "Valve Groups",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Obx(() {
              return Column(
                children: controller.groupedValves.map((group) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ExpansionTile(
                      title: Text(group.name),
                      subtitle: Text("Group ID: ${group.id}"),
                      trailing: Obx(() {
                        return Switch(
                          value:
                              controller.groupToggleStates[group.id]?.value ??
                              false,
                          onChanged: (_) {
                            controller.toggleValveGroup(
                              groupId: group.id,
                              token: token,
                              farmId: farmId,
                            );
                          },
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.red,
                        );
                      }),

                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final screenWidth = MediaQuery.of(
                                context,
                              ).size.width;
                              final crossAxisCount = screenWidth < 600 ? 2 : 3;

                              return SizedBox(
                                height:
                                    ((group.valves.length / crossAxisCount)
                                        .ceil()) *
                                    140,
                                child: SizedBox(
                                  height: 350, // Adjust based on your needs
                                  child: GridView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          mainAxisSpacing: 12,
                                          crossAxisSpacing: 12,
                                          childAspectRatio:
                                              1.3, // Reduced from 2.8
                                        ),
                                    itemCount: group.valves.length,
                                    itemBuilder: (context, index) {
                                      final valve = group.valves[index];
                                      return Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              valve.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Lora: ${valve.loraId}',
                                              style: TextStyle(fontSize: 12),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  valve.status == "ON"
                                                      ? "Opened"
                                                      : "Closed",
                                                  style: TextStyle(
                                                    color: valve.status == "ON"
                                                        ? Colors.green
                                                        : Colors.red,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),

                                                IconButton(
                                                  icon: Icon(
                                                    valve.status == "ON"
                                                        ? Icons.toggle_on
                                                        : Icons.toggle_off,
                                                    color: valve.status == "ON"
                                                        ? Colors.green
                                                        : Colors.grey,
                                                    size: 45,
                                                  ),
                                                  onPressed: () {
                                                    final newStatus =
                                                        valve.status == "ON"
                                                        ? "OFF"
                                                        : "ON";
                                                    controller.toggleValve(
                                                      valveId: valve.id,
                                                      status: newStatus,
                                                      token: token,
                                                      farmId: farmId,
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
            SizedBox(height: 16),
            Text(
              "Ungrouped Valves",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Obx(() {
              if (controller.ungroupedValves.isEmpty) {
                return Text("No ungrouped valves found.");
              }

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: controller.ungroupedValves.map((valve) {
                  return Container(
                    width: MediaQuery.of(context).size.width / 2 - 24,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          valve.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Lora: ${valve.loraId}',
                          style: TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 1),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              valve.status == "ON" ? "Opened" : "Closed",
                              style: TextStyle(
                                color: valve.status == "ON"
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(
                                  valve.status == "ON"
                                      ? Icons.toggle_on
                                      : Icons.toggle_off,
                                  color: valve.status == "ON"
                                      ? Colors.green
                                      : Colors.grey,
                                  size: 50,
                                ),
                                onPressed: () {
                                  final newStatus = valve.status == "ON"
                                      ? "OFF"
                                      : "ON";
                                  controller.toggleValve(
                                    valveId: valve.id,
                                    status: newStatus,
                                    token: token,
                                    farmId: farmId,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
            // Paste everything from the original MotorListPage body here
            // starting from `Text("In Motors")` to end of "Ungrouped Valves"
          ],
        ),
      );
    });
  }
}
