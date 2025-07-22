class Valve {
  final int id;
  final String name;
  final String loraId;
  final bool isActive;
  final String status;
  final String createdAt;
  final String updatedAt;
  final int motor;

  Valve({
    required this.id,
    required this.name,
    required this.loraId,
    required this.isActive,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.motor,
  });

  factory Valve.fromJson(Map<String, dynamic> json) {
    return Valve(
      id: json['id'],
      name: json['name'],
      loraId: json['lora_id'],
      isActive: json['is_active'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      motor: json['motor'],
    );
  }
}
