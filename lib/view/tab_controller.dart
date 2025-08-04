import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/motorlist_controller.dart';
import 'package:smartfarm/view/motors.dart';
import 'package:smartfarm/view/schedulepage.dart';
import 'package:smartfarm/view/valve_grouping.dart';

class IoTDashboardPage extends StatefulWidget {
  final int farmId;
  final String token;

  IoTDashboardPage({super.key, required this.farmId, required this.token});

  @override
  State<IoTDashboardPage> createState() => _IoTDashboardPageState();
}

class _IoTDashboardPageState extends State<IoTDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MotorController controller = Get.put(MotorController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    controller.fetchMotorsAndValves(widget.farmId, widget.token);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IoT Dashboard"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.precision_manufacturing),
              text: "Motors & Valves",
            ),
            Tab(icon: Icon(Icons.schedule), text: "Schedule"),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.to(
                () =>
                    ValveGroupPage(farmId: widget.farmId, token: widget.token),
              );
            },
            child: const Text("Valve Grouping"),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          /// Tab 1: Motor and Valve List
          MotorListTab(farmId: widget.farmId, token: widget.token),

          /// Tab 2: Schedule Page
          SchedulePage(
            farmId: widget.farmId,
            token: widget.token,
          ), // Replace with your actual widget
        ],
      ),
    );
  }
}
