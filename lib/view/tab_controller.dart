import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/motorlist_controller.dart';
import 'package:smartfarm/view/motors.dart';
import 'package:smartfarm/view/schedulepage.dart';
import 'package:smartfarm/view/valve_grouping.dart';

class IoTDashboardPage extends StatefulWidget {
  final int farmId;
  final String token;

  const IoTDashboardPage({
    super.key,
    required this.farmId,
    required this.token,
  });

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
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.green[800],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green.withOpacity(0.15),
                Colors.green.withOpacity(0.05),
              ],
            ),
          ),
        ),
        title: Row(
          children: [
            // Container(
            //   padding: const EdgeInsets.all(8),
            //   decoration: BoxDecoration(
            //     color: Colors.green.withOpacity(0.2),
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Icon(Icons.eco, color: Colors.green[700], size: 24),
            // ),
            const SizedBox(width: 12),
            Text(
              "Smart Farm",
              style: TextStyle(
                color: Colors.green[800],
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.green.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.8),
                    Colors.green[600]!.withOpacity(0.9),
                  ],
                ),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.green[700],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              tabs: [
                Tab(
                  height: 40,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.precision_manufacturing_rounded, size: 18),
                      const SizedBox(width: 6),
                      const Text("Motors & Valves"),
                    ],
                  ),
                ),
                Tab(
                  height: 40,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule_rounded, size: 18),
                      const SizedBox(width: 6),
                      const Text("Schedule"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Colors.green[400]!.withOpacity(0.9),
                    Colors.green[600]!.withOpacity(0.9),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Get.to(
                    () => ValveGroupPage(
                      farmId: widget.farmId,
                      token: widget.token,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_tree_rounded, size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      "Valve Grouping",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //     colors: [
        //       Colors.green.withOpacity(0.05),
        //       Colors.white.withOpacity(0.9),
        //       Colors.green.withOpacity(0.02),
        //     ],
        //   ),
        // ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 120,
          ), // Account for transparent app bar
          child: TabBarView(
            controller: _tabController,
            children: [
              /// Tab 1: Motor and Valve List
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: MotorListTab(
                    farmId: widget.farmId,
                    token: widget.token,
                  ),
                ),
              ),

              /// Tab 2: Schedule Page
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SchedulePage(
                    farmId: widget.farmId,
                    token: widget.token,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
