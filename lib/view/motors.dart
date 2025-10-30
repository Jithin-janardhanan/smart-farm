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
              _buildTelemetryGraph(),

              _buildLiveDataCard(),
              const SizedBox(height: 24),

              _buildMotorsSection(),
              const SizedBox(height: 24),
              _buildValvesSection(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTelemetryGraph() {
    return Obx(() {
      final telemetryList = controller.telemetryData;
      if (telemetryList.isEmpty) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                "No telemetry data available",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ),
        );
      }

      // Calculate min/max for better axis scaling
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

      // Add padding to min/max
      final voltageRange = maxVoltage - minVoltage;
      minVoltage = minVoltage - (voltageRange * 0.1);
      maxVoltage = maxVoltage + (voltageRange * 0.1);

      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Voltage Graph",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${telemetryList.length} readings",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Legend
              Wrap(
                spacing: 16,
                children: [
                  _buildLegendItem(Colors.blue, "R Phase"),
                  _buildLegendItem(Colors.amber, "Y Phase"),
                  _buildLegendItem(Colors.red, "B Phase"),
                ],
              ),

              const SizedBox(height: 12),
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    backgroundColor: Colors.white,
                    minY: minVoltage,
                    maxY: maxVoltage,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: (maxVoltage - minVoltage) / 5,
                      verticalInterval: telemetryList.length > 10
                          ? (telemetryList.length / 10).ceilToDouble()
                          : 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade300,
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        );
                      },
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
                              value.toStringAsFixed(1) + 'V',
                              style: const TextStyle(fontSize: 10),
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
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => Colors.black87,
                        tooltipBorder: BorderSide(color: Colors.grey.shade700),
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
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
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
                              color: Colors.grey.shade400,
                              strokeWidth: 2,
                              dashArray: [3, 3],
                            ),
                            FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  strokeColor: barData.color ?? Colors.blue,
                                );
                              },
                            ),
                          );
                        }).toList();
                      },
                    ),
                    lineBarsData: [
                      // 🔵 Voltage R
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
                        color: Colors.blue,
                        barWidth: 2.5,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                      // 🟡 Voltage Y
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
                        color: Colors.amber,
                        barWidth: 2.5,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                      // 🔴 Voltage B
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
                        color: Colors.red,
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

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildLiveDataCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Top row: Power icon + Farm name + Status + Refresh
              Row(
                children: [
                  // Power icon
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
                        color: isMotorRunning ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isMotorRunning ? Icons.power : Icons.power_off,
                        color: Colors.white,
                        size: 20,
                      ),
                    );
                  }),
                  const SizedBox(width: 12),

                  // Farm name + Status
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            isMotorRunning
                                ? "System Running"
                                : "System Offline",
                            style: TextStyle(
                              color: isMotorRunning
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),

                  // Refresh button
                  IconButton(
                    onPressed: () => controller.fetchLiveData(token, farmId),
                    icon: const Icon(Icons.refresh),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// 🔹 Values box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
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
                              "Voltage",
                              data.voltage
                                  .map((v) => '${v.toStringAsFixed(1)}V')
                                  .join(', '),
                              Icons.electrical_services,
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDataItem(
                              "Current R",
                              "${data.currentR.toStringAsFixed(2)} A",
                              Icons.circle,
                              Colors.red,
                            ),
                          ),
                          Expanded(
                            child: _buildDataItem(
                              "Current Y",
                              "${data.currentY.toStringAsFixed(2)} A",
                              Icons.circle,
                              Colors.yellow.shade700,
                            ),
                          ),
                          Expanded(
                            child: _buildDataItem(
                              "Current B",
                              "${data.currentB.toStringAsFixed(2)} A",
                              Icons.circle,
                              Colors.blue,
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
      ),
    );
  }

  Widget _buildDataItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildMotorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Motors", Icons.settings, Colors.blue),
        const SizedBox(height: 12),
        _buildInMotors(),
        const SizedBox(height: 16),
        _buildOutMotors(),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
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
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInMotors() {
    if (controller.inMotors.isEmpty) {
      return _buildEmptyState("No In motors available", Icons.settings);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "In Motors",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        ...controller.inMotors.map((motor) => _buildMotorCard(motor, true)),
      ],
    );
  }

  Widget _buildOutMotors() {
    if (controller.outMotors.isEmpty) {
      return _buildEmptyState("No Out motors available", Icons.settings);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Out Motors",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        ...controller.outMotors.map((motor) => _buildMotorCard(motor, false)),
      ],
    );
  }

  Widget _buildMotorCard(dynamic motor, bool isInMotor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: isInMotor
          ? Obx(() => _buildMotorCardContent(motor, isInMotor))
          : _buildMotorCardContent(motor, isInMotor),
    );
  }

  Widget _buildMotorCardContent(dynamic motor, bool isInMotor) {
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
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.settings,
              color: isOn ? Colors.green : Colors.grey,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'LoRa ID: ${motor.loraId}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isOn
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isOn ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
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
              activeThumbColor: Colors.green,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildValvesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Valves", Icons.water_drop, Colors.blue),
        const SizedBox(height: 12),
        _buildGroupedValves(),
        const SizedBox(height: 16),
        _buildUngroupedValves(),
      ],
    );
  }

  Widget _buildGroupedValves() {
    return Obx(() {
      final groups = controller.groupedValves;
      if (groups.isEmpty) {
        return _buildEmptyState(
          "No grouped valves available",
          Icons.water_drop,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Grouped Valves",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          ...groups.map((group) => _buildGroupCard(group)),
        ],
      );
    });
  }

  Widget _buildGroupCard(dynamic group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(bottom: 12),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.water_drop, color: Colors.blue, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "ID: ${group.id} • ${group.valves.length} valves",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
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
              activeThumbColor: Colors.blue,
            );
          }),
          children: group.valves
              .map<Widget>((valve) => _buildValveItem(valve))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildValveItem(dynamic valve) {
    final isOn = valve.status == "ON";
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isOn ? Icons.water_drop : Icons.water_drop_outlined,
            color: isOn ? Colors.blue : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valve.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "LoRa: ${valve.loraId}",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isOn
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isOn ? "Open" : "Closed",
              style: TextStyle(
                color: isOn ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 11,
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
              activeThumbColor: Colors.blue,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUngroupedValves() {
    return Obx(() {
      if (controller.ungroupedValves.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Individual Valves",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            _buildEmptyState(
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
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
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 1,
                  ),
                  leading: Icon(
                    isOn ? Icons.water_drop : Icons.water_drop_outlined,
                    color: isOn ? Colors.blue : Colors.grey,
                    size: 18,
                  ),
                  title: Text(
                    valve.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    "LoRa: ${valve.loraId}",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isOn
                                ? Colors.green.shade700
                                : Colors.red.shade700,
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
                          activeThumbColor: Colors.blue,
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

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
