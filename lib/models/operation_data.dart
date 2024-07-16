class OperationItem {
  OperationItem({
    required this.id,
    required this.name,
    required this.type,
  });

  late final int id;
  late final String name;
  late final int type;

  OperationItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'] ?? '';
    type = json['type'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['type'] = type;
    return data;
  }
}
