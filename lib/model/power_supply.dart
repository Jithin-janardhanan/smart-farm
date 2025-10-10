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
  final voltageList = (json['voltage'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
      [0.0, 0.0, 0.0];

  final currentList = (json['current'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
      [0.0, 0.0, 0.0];

  return LiveData(
    id: json['id'] ?? 0,
    farmName: json['farm_name'] ?? '',
    voltage: voltageList,
    currentR: currentList.isNotEmpty ? currentList[0] : 0.0,
    currentY: currentList.length > 1 ? currentList[1] : 0.0,
    currentB: currentList.length > 2 ? currentList[2] : 0.0,
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
