class Motor {
  final int id;
  final String name;
  final String loraId;
  final bool isActive;
  final String farm;
  final String createdAt;
  final String updatedAt;

  Motor({
    required this.id,
    required this.name,
    required this.loraId,
    required this.isActive,
    required this.farm,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Motor.fromJson(Map<String, dynamic> json) {
    return Motor(
      id: json['id'],
      name: json['name'],
      loraId: json['lora_id'],
      isActive: json['is_active'],
      farm: json['farm'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
