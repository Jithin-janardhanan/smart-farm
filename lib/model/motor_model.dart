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
  final Rx<DateTime?> timerStartAt;
  final Rx<DateTime?> timerEndAt;

  Motor({
    required this.id,
    required this.name,
    required String displayName,
    required String loraId,
    required this.phaseType,
    required this.valveCount,
    required this.unitNumber,
    required String status,
    DateTime? timerStartAt,
    DateTime? timerEndAt,
  })  : displayname = displayName.obs,
        loraId = loraId.obs,
        status = status.obs,
        timerStartAt = Rx<DateTime?>(timerStartAt),
        timerEndAt = Rx<DateTime?>(timerEndAt);

  /// True when a timed run is active (motor ON and end time is in the future)
  bool get isTimedRunActive {
    final end = timerEndAt.value;
    return status.value == "ON" &&
        end != null &&
        end.isAfter(DateTime.now());
  }

  /// Remaining duration (null if no active timed run)
  Duration? get remainingDuration {
    if (!isTimedRunActive) return null;
    final diff = timerEndAt.value!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  factory Motor.fromJson(Map<String, dynamic> json) {
    return Motor(
      id: json['id'],
      name: json['name'],
      displayName: json['display_name'] ?? '',
      loraId: json['lora_id'] ?? '',
      phaseType: json['phase_type'] ?? '',
      valveCount: json['valve_count'] ?? 0,
      unitNumber: json['unit_number'],
      status: json['status'] ?? 'OFF',
      timerStartAt: json['timer_start_at'] != null
          ? DateTime.parse(json['timer_start_at']).toLocal()
          : null,
      timerEndAt: json['timer_end_at'] != null
          ? DateTime.parse(json['timer_end_at']).toLocal()
          : null,
    );
  }
}