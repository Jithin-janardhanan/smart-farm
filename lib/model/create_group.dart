//creating groups of valves

class ValveGroupRequest {
  final int farm;
  final String name;
  final List<int> valveIds;

  ValveGroupRequest({
    required this.farm,
    required this.name,
    required this.valveIds,
  });

  Map<String, dynamic> toJson() => {
    'farm': farm,
    'name': name,
    'valve_ids': valveIds,
  };
}
