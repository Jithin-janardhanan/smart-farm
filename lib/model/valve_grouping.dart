class ValveGrouping  {
  final int id;
  final String name;
  final String loraId;
  final String direction;
  final String status;

  ValveGrouping ({
    required this.id,
    required this.name,
    required this.loraId,
    required this.direction,
    required this.status,
  });

  factory ValveGrouping.fromJson(Map<String, dynamic> json) {
    return ValveGrouping(
      id: json['id'],
      name: json['name'],
      loraId: json['lora_id'],
      direction: json['direction'],
      status: json['status'],
    );
  }
}
