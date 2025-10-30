import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/motorlist_controller.dart';
import 'package:smartfarm/model/power_supply.dart';

class MotorListTab extends StatelessWidget {
  final int farmId;
  final String token;

  MotorListTab({super.key, required this.farmId, required this.token});

  final MotorController controller = Get.find<MotorController>();

  @override
  Widget build(BuildContext context) {
    controller.startLiveDataUpdates(token, farmId);
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading farm data...'),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await controller.fetchAllData(token, farmId);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTelemetryGraph(context),

              _buildLiveDataCard(context),
              const SizedBox(height: 24),

              _buildMotorsSection(context),
              const SizedBox(height: 24),
              _buildValvesSection(context),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTelemetryGraph(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Obx(() {
      final telemetryList = controller.telemetryData;
      final isLoading = controller.isLoading.value;

      if (isLoading) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (telemetryList.isEmpty) {
        return Card(
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                "No telemetry data available",
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ),
        );
      }

      // ✅ Calculate min/max for scaling
      double minVoltage = double.infinity;
      double maxVoltage = double.negativeInfinity;

      for (var data in telemetryList) {
        minVoltage = [
          minVoltage,
          data.voltageR,
          data.voltageY,
          data.voltageB,
        ].reduce((a, b) => a < b ? a : b);
        maxVoltage = [
          maxVoltage,
          data.voltageR,
          data.voltageY,
          data.voltageB,
        ].reduce((a, b) => a > b ? a : b);
      }

      final voltageRange = maxVoltage - minVoltage;
      minVoltage -= (voltageRange * 0.1);
      maxVoltage += (voltageRange * 0.1);

      return Card(
        elevation: 4,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Voltage Graph",
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${telemetryList.length} readings",
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// 🔹 Legend
              Wrap(
                spacing: 16,
                children: [
                  _buildLegendItem(
                    context,
                    Colors.blue,
                    "R Phase",
                  ), // Keep phase-specific colors
                  _buildLegendItem(context, Colors.amber, "Y Phase"),
                  _buildLegendItem(context, Colors.red, "B Phase"),
                ],
              ),

              const SizedBox(height: 12),

              /// 🔹 Chart
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    backgroundColor: colorScheme.surface,
                    minY: minVoltage,
                    maxY: maxVoltage,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: (maxVoltage - minVoltage) / 5,
                      verticalInterval: telemetryList.length > 10
                          ? (telemetryList.length / 10).ceilToDouble()
                          : 1,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: colorScheme.onSurface.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: colorScheme.onSurface.withOpacity(0.05),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 42,
                          interval: (maxVoltage - minVoltage) / 5,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              "${value.toStringAsFixed(1)}V",
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: telemetryList.length > 6
                              ? (telemetryList.length / 6).ceilToDouble()
                              : 1,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index < 0 || index >= telemetryList.length) {
                              return const SizedBox();
                            }
                            final date = telemetryList[index].timestamp;
                            final formatted =
                                "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                formatted,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: colorScheme.onSurface.withOpacity(0.2),
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) =>
                            colorScheme.inverseSurface,
                        tooltipBorder: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
                        tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        tooltipMargin: 8,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final index = spot.x.toInt();
                            if (index >= 0 && index < telemetryList.length) {
                              final data = telemetryList[index];
                              String label = '';
                              if (spot.barIndex == 0) label = 'R: ';
                              if (spot.barIndex == 1) label = 'Y: ';
                              if (spot.barIndex == 2) label = 'B: ';
                              return LineTooltipItem(
                                '$label${spot.y.toStringAsFixed(2)}V\n${data.timestamp.hour}:${data.timestamp.minute.toString().padLeft(2, '0')}',
                                textTheme.bodyMedium!.copyWith(
                                  color: colorScheme.onInverseSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }
                            return null;
                          }).toList();
                        },
                      ),
                      handleBuiltInTouches: true,
                      getTouchedSpotIndicator: (barData, spotIndexes) {
                        return spotIndexes.map((index) {
                          return TouchedSpotIndicatorData(
                            FlLine(
                              color: colorScheme.outlineVariant,
                              strokeWidth: 2,
                              dashArray: [3, 3],
                            ),
                            FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: colorScheme.surface,
                                  strokeWidth: 2,
                                  strokeColor:
                                      barData.color ?? colorScheme.primary,
                                );
                              },
                            ),
                          );
                        }).toList();
                      },
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: telemetryList
                            .asMap()
                            .entries
                            .map(
                              (e) => FlSpot(
                                e.key.toDouble(),
                                e.value.voltageR.toDouble(),
                              ),
                            )
                            .toList(),
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: Colors.blue, // Keep phase color
                        barWidth: 2.5,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                      LineChartBarData(
                        spots: telemetryList
                            .asMap()
                            .entries
                            .map(
                              (e) => FlSpot(
                                e.key.toDouble(),
                                e.value.voltageY.toDouble(),
                              ),
                            )
                            .toList(),
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: Colors.amber, // Keep phase color
                        barWidth: 2.5,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                      LineChartBarData(
                        spots: telemetryList
                            .asMap()
                            .entries
                            .map(
                              (e) => FlSpot(
                                e.key.toDouble(),
                                e.value.voltageB.toDouble(),
                              ),
                            )
                            .toList(),
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: Colors.red, // Keep phase color
                        barWidth: 2.5,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// 🔹 Legend item
  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: textTheme.bodySmall),
      ],
    );
  }

  Widget _buildLiveDataCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Top Row: Power Icon + Farm Name + Status + Refresh
            Row(
              children: [
                // Power Icon
                Obx(() {
                  final data = controller.liveData.value ?? LiveData.zero();
                  final isMotorRunning =
                      !(data.voltage.every((v) => v == 0.0) &&
                          data.currentR == 0.0 &&
                          data.currentY == 0.0 &&
                          data.currentB == 0.0);

                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isMotorRunning
                          ? colorScheme.primary
                          : colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isMotorRunning ? Icons.power : Icons.power_off,
                      color:
                          colorScheme.onPrimary, // Use onPrimary for contrast
                      size: 20,
                    ),
                  );
                }),
                const SizedBox(width: 12),

                // Farm name + status
                Expanded(
                  child: Obx(() {
                    final data = controller.liveData.value ?? LiveData.zero();
                    final isMotorRunning =
                        !(data.voltage.every((v) => v == 0.0) &&
                            data.currentR == 0.0 &&
                            data.currentY == 0.0 &&
                            data.currentB == 0.0);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.farmName,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isMotorRunning ? "System Running" : "System Offline",
                          style: textTheme.bodyMedium?.copyWith(
                            color: isMotorRunning
                                ? colorScheme.primary
                                : colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  }),
                ),

                // Refresh Button
                IconButton(
                  onPressed: () => controller.fetchLiveData(token, farmId),
                  icon: const Icon(Icons.refresh),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surface,
                    shape: const CircleBorder(),
                    foregroundColor: colorScheme.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// 🔹 Values Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (theme.brightness == Brightness.light)
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Obx(() {
                final data = controller.liveData.value ?? LiveData.zero();

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildDataItem(
                            context,
                            "Voltage",
                            data.voltage
                                .map((v) => '${v.toStringAsFixed(1)}V')
                                .join(', '),
                            Icons.electrical_services,
                            colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDataItem(
                            context,
                            "Current R",
                            "${data.currentR.toStringAsFixed(2)} A",
                            Icons.circle,
                            Colors.redAccent, // Keep phase-specific
                          ),
                        ),
                        Expanded(
                          child: _buildDataItem(
                            context,
                            "Current Y",
                            "${data.currentY.toStringAsFixed(2)} A",
                            Icons.circle,
                            Colors.amberAccent, // Keep phase-specific
                          ),
                        ),
                        Expanded(
                          child: _buildDataItem(
                            context,
                            "Current B",
                            "${data.currentB.toStringAsFixed(2)} A",
                            Icons.circle,
                            Colors.lightBlueAccent, // Keep phase-specific
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Reusable data item builder
  Widget _buildDataItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMotorsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          "Motors",
          Icons.settings,
          colorScheme.primary,
        ),
        const SizedBox(height: 12),
        _buildInMotors(context),
        const SizedBox(height: 16),
        _buildOutMotors(context),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInMotors(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (controller.inMotors.isEmpty) {
      return _buildEmptyState(
        context,
        "No In motors available",
        Icons.settings,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "In Motors",
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        ...controller.inMotors.map(
          (motor) => _buildMotorCard(context, motor, true),
        ),
      ],
    );
  }

  Widget _buildOutMotors(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (controller.outMotors.isEmpty) {
      return _buildEmptyState(
        context,
        "No Out motors available",
        Icons.settings,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Out Motors",
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        ...controller.outMotors.map(
          (motor) => _buildMotorCard(context, motor, false),
        ),
      ],
    );
  }

  Widget _buildMotorCard(BuildContext context, dynamic motor, bool isInMotor) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surface,
      child: isInMotor
          ? Obx(() => _buildMotorCardContent(context, motor, isInMotor))
          : _buildMotorCardContent(context, motor, isInMotor),
    );
  }

  Widget _buildMotorCardContent(
    BuildContext context,
    dynamic motor,
    bool isInMotor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final status = motor.status.value;
    final isOn = status == "ON";

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isOn
                  ? colorScheme.primary.withOpacity(0.1)
                  : colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.settings,
              color: isOn ? colorScheme.primary : colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  motor.name,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'LoRa ID: ${motor.loraId}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isOn
                        ? colorScheme.primary.withOpacity(0.1)
                        : colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: textTheme.bodySmall?.copyWith(
                      color: isOn ? colorScheme.primary : colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 👇 Loader or Switch
          Obx(() {
            final isLoading = controller.motorLoading[motor.id]?.value ?? false;
            if (isLoading) {
              return const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }
            return Switch(
              value: isOn,
              onChanged: (_) {
                final newStatus = isOn ? "OFF" : "ON";
                controller.toggleMotor(
                  motorId: motor.id,
                  status: newStatus,
                  farmId: farmId,
                  token: token,
                );
              },
              activeColor: colorScheme.primary,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildValvesSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          "Valves",
          Icons.water_drop,
          colorScheme.secondary,
        ),
        const SizedBox(height: 12),
        _buildGroupedValves(context),
        const SizedBox(height: 16),
        _buildUngroupedValves(context),
      ],
    );
  }

  Widget _buildGroupedValves(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Obx(() {
      final groups = controller.groupedValves;
      if (groups.isEmpty) {
        return _buildEmptyState(
          context,
          "No grouped valves available",
          Icons.water_drop,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Grouped Valves",
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          ...groups.map((group) => _buildGroupCard(context, group)),
        ],
      );
    });
  }

  Widget _buildGroupCard(BuildContext context, dynamic group) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surface,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(bottom: 12),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.water_drop,
                  color: colorScheme.secondary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "ID: ${group.id} • ${group.valves.length} valves",
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          trailing: Obx(() {
            final isLoading = controller.groupLoading[group.id]?.value ?? false;
            if (isLoading) {
              return const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }
            return Switch(
              value: controller.groupToggleStates[group.id]?.value ?? false,
              onChanged: (_) {
                controller.toggleValveGroup(
                  groupId: group.id,
                  token: token,
                  farmId: farmId,
                );
              },
              activeColor: colorScheme.secondary,
            );
          }),
          children: group.valves
              .map<Widget>((valve) => _buildValveItem(context, valve))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildValveItem(BuildContext context, dynamic valve) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isOn = valve.status == "ON";
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isOn ? Icons.water_drop : Icons.water_drop_outlined,
            color: isOn ? colorScheme.secondary : colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valve.name,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "LoRa: ${valve.loraId}",
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isOn
                  ? colorScheme.secondary.withOpacity(0.1)
                  : colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isOn ? "Open" : "Closed",
              style: textTheme.labelSmall?.copyWith(
                color: isOn ? colorScheme.secondary : colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            final isLoading = controller.valveLoading[valve.id]?.value ?? false;
            if (isLoading) {
              return const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }
            return Switch(
              value: isOn,
              onChanged: (_) {
                final newStatus = isOn ? "OFF" : "ON";
                controller.toggleValve(
                  valveId: valve.id,
                  status: newStatus,
                  token: token,
                  farmId: farmId,
                );
              },
              activeColor: colorScheme.secondary,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUngroupedValves(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Obx(() {
      if (controller.ungroupedValves.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Individual Valves",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            _buildEmptyState(
              context,
              "No individual valves available",
              Icons.water_drop,
            ),
          ],
        );
      }

      // ✅ Sort by ID (ascending). For descending just swap a.id with b.id
      final sortedValves = controller.ungroupedValves.toList()
        ..sort((a, b) => a.id.compareTo(b.id));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Individual Valves",
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: sortedValves.length,
            itemBuilder: (context, index) {
              final valve = sortedValves[index];
              final isOn = valve.status == "ON";

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                color: colorScheme.surface,
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 1,
                  ),
                  leading: Icon(
                    isOn ? Icons.water_drop : Icons.water_drop_outlined,
                    color: isOn
                        ? colorScheme.secondary
                        : colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  title: Text(
                    valve.name,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    "LoRa: ${valve.loraId}",
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Obx(() {
                    final isLoading =
                        controller.valveLoading[valve.id]?.value ?? false;
                    if (isLoading) {
                      return const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isOn ? "Open" : "Closed",
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isOn
                                ? colorScheme.secondary
                                : colorScheme.error,
                          ),
                        ),
                        Switch(
                          value: isOn,
                          onChanged: (_) {
                            final newStatus = isOn ? "OFF" : "ON";
                            controller.toggleValve(
                              valveId: valve.id,
                              status: newStatus,
                              token: token,
                              farmId: farmId,
                            );
                          },
                          activeColor: colorScheme.secondary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    );
                  }),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            message,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
