// lib/model/live_data_model.dart
class LiveData {
  final int id;
  final String farmName;
  final List<double> voltage;
  final double currentR;
  final double currentY;
  final double currentB;

  LiveData({
     required this.id,
    required this.farmName,
    required this.voltage,
    required this.currentR,
    required this.currentY,
    required this.currentB,
  });

  factory LiveData.fromJson(Map<String, dynamic> json) {
    return LiveData(
      id: json['id'] ?? 0,
      farmName: json['farm_name'] ?? '',
      voltage: (json['voltage'] as List<dynamic>? ?? [0.0, 0.0, 0.0])
          .map((v) => (v as num).toDouble())
          .toList(),
      currentR: (json['current_r'] as num?)?.toDouble() ?? 0.0,
      currentY: (json['current_y'] as num?)?.toDouble() ?? 0.0,
      currentB: (json['current_b'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Default data with zeros — useful when no live data
  factory LiveData.zero({String farmName = ''}) {
    return LiveData(
      id: 0,
      farmName: farmName,
      voltage: [0.0, 0.0, 0.0],
      currentR: 0.0,
      currentY: 0.0,
      currentB: 0.0,
    );
  }
}


