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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.15),
                colorScheme.surface.withOpacity(0.7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Row(
          children: [
            const SizedBox(width: 12),
            Text(
              "Smart Farm",
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.1),
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
                    colorScheme.primary.withOpacity(0.8),
                    colorScheme.secondary.withOpacity(0.9),
                  ],
                ),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: colorScheme.primary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              tabs: const [
                Tab(
                  height: 40,
                  icon: Icon(Icons.precision_manufacturing_rounded, size: 18),
                  text: "Motors & Valves",
                ),
                Tab(
                  height: 40,
                  icon: Icon(Icons.schedule_rounded, size: 18),
                  text: "Schedule",
                ),
              ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                Get.to(
                  () => ValveGroupPage(
                    farmId: widget.farmId,
                    token: widget.token,
                  ),
                );
              },
              icon: const Icon(Icons.account_tree_rounded, size: 18),
              label: const Text(
                "Valve Grouping",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: colorScheme.primary.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 120),
        child: TabBarView(
          controller: _tabController,
          children: [
            /// 🌿 Tab 1: Motors & Valves
            _buildThemedContainer(
              theme,
              MotorListTab(farmId: widget.farmId, token: widget.token),
            ),

            /// 🕒 Tab 2: Schedule
            _buildThemedContainer(
              theme,
              SchedulePage(farmId: widget.farmId, token: widget.token),
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable themed card container for tab content
  Widget _buildThemedContainer(ThemeData theme, Widget child) {
    final colorScheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(20), child: child),
    );
  }
}
