
class Schedule {
  final int id;
  final String batchId;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final bool isActive;
  final int motorId;
  final int? valveGroupId;
  final List<int> valves;

  Schedule({
    required this.id,
    required this.batchId,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    required this.motorId,
    required this.valveGroupId,
    required this.valves,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      batchId: json['batch_id'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      isActive: json['is_active'],
      motorId: json['motor'],
      valveGroupId: json['valve_group'],
      valves: List<int>.from(json['valves']),
    );
  }
}
