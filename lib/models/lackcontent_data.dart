class LackContent {
  LackContent({
    required this.id,
    this.code,
    required this.name,
    this.parent,
    required this.qualityType,
    required this.isSafty,
    required this.isImmediate,
    required this.childList,
  });

  late final int id;
  late final String? code;
  late final String name;
  late final String? parent;
  late final int qualityType;
  late final bool isSafty;
  late final bool isImmediate;
  late final List<LackContent> childList;

  factory LackContent.fromJson(Map<String, dynamic> json) {
    return LackContent(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      parent: json['parent'],
      qualityType: json['qualityType'],
      isSafty: json['isSafty'],
      isImmediate: json['isImmediate'],
      childList: (json['childList'] as List?)
              ?.map((child) => LackContent.fromJson(child))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'parent': parent,
      'qualityType': qualityType,
      'isSafty': isSafty,
      'isImmediate': isImmediate,
      'childList': childList.map((child) => child.toJson()).toList(),
    };
  }
}
