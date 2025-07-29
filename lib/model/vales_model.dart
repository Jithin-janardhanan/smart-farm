//individuals vale listing
class Valve {
  final int id;
  final String name;
  final String loraId;
  final String status;

  Valve({
    required this.id,
    required this.name,
    required this.loraId,
    required this.status,
  });

  factory Valve.fromJson(Map<String, dynamic> json) {
    return Valve(
      id: json['id'],
      name: json['name'],
      loraId: json['lora_id'],
      status: json['status'],
    );
  }
}