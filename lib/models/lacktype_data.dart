class LackType {
  LackType({
    required this.id,
    required this.code,
    required this.name,
  });

  late final int id;
  late final String code;
  late final String name;

  LackType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'] ?? '';
    name = json['name'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    return data;
  }
}
