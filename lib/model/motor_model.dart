class Motor {
  final int id;
  final String name;
  final String loraId;
  final String phaseType;
  final int valveCount;
  final int unitNumber;
  final String status;

  Motor({
    required this.id,
    required this.name,
    required this.loraId,
    required this.phaseType,
    required this.valveCount,
    required this.unitNumber,
    required this.status,
  });

  factory Motor.fromJson(Map<String, dynamic> json) {
    return Motor(
      id: json['id'],
      name: json['name'],
      loraId: json['lora_id'],
      phaseType: json['phase_type'],
      valveCount: json['valve_count'],
      unitNumber: json['unit_number'],
      status: json['status'],
    );
  }
}


