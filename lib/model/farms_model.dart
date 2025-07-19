class Farm {
  final int id;
  final String farmName;
  final String location;
  final String farmArea;
  final String gsmNumber;

  Farm({
    required this.id,
    required this.farmName,
    required this.location,
    required this.farmArea,
    required this.gsmNumber,
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'],
      farmName: json['farm_name'] ?? '',
      location: json['location'] ?? '',
      farmArea: json['farm_area'] ?? '',
      gsmNumber: json['gsm_number'] ?? '',
    );
  }
}
