//listing of valves by groups
import 'package:smartfarm/model/valve_grouping.dart';

class ValveGroup {
  final int id;
  final int farm;
  final String name;
  final List<ValveGrouping> valves;

  ValveGroup({
    required this.id,
    required this.farm,
    required this.name,
    required this.valves,
  });

  factory ValveGroup.fromJson(Map<String, dynamic> json) {
    return ValveGroup(
      id: json['id'],
      farm: json['farm'],
      name: json['name'],
      valves: (json['valves'] as List)
          .map((v) => ValveGrouping.fromJson(v['valve']))
          .toList(),
    );
  }
}
