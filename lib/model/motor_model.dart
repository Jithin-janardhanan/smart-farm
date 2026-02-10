
import 'package:get/get.dart';

class Motor {
  final int id;
  final String name;
  final RxString displayname;
  final RxString loraId;
  final String phaseType;
  final int valveCount;
  final int? unitNumber;
  final RxString status;

  Motor({
    required this.id,
    required this.name,
    required String displayname,
    required String loraId,
    required this.phaseType,
    required this.valveCount,
    required this.unitNumber,
    required String status,
  })  : displayname = displayname.obs,
        loraId = loraId.obs,
        status = status.obs;

  factory Motor.fromJson(Map<String, dynamic> json) {
    return Motor(
      id: json['id'],
      name: json['name'],
      displayname: json['display_name'] ?? '',
      loraId: json['lora_id'],
      phaseType: json['phase_type'],
      valveCount: json['valve_count'],
      unitNumber: json['unit_number'],
      status: json['status'],
    );
  }
}
