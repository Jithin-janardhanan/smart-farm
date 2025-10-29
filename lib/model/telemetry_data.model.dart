class TelemetryData {
  final DateTime timestamp;
  final double voltageR;
  final double voltageY;
  final double voltageB;
  final double currentR;
  final double currentY;
  final double currentB;

  TelemetryData({
    required this.timestamp,
    required this.voltageR,
    required this.voltageY,
    required this.voltageB,
    required this.currentR,
    required this.currentY,
    required this.currentB,
  });

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    return TelemetryData(
      timestamp: DateTime.parse(json['timestamp']),
      voltageR: (json['voltage_r'] ?? 0).toDouble(),
      voltageY: (json['voltage_y'] ?? 0).toDouble(),
      voltageB: (json['voltage_b'] ?? 0).toDouble(),
      currentR: (json['current_r'] ?? 0).toDouble(),
      currentY: (json['current_y'] ?? 0).toDouble(),
      currentB: (json['current_b'] ?? 0).toDouble(),
    );
  }
}
