class Lack {
  Lack({
    required this.id,
    required this.roundId,
    this.uuid,
    this.location,
    this.qualityLackingTypeId,
    this.qualityLackingTypeName,
    this.lackContentName,
    this.lackingTypeId,
    this.lackingTypeName,
    this.tertiaryMediaId,
    this.tertiaryMediaName,
    required this.immediate,
    required this.improvementDeadline,
    this.photos,
  });

  late int id;
  late int roundId;
  late String? uuid;
  late String? location;
  late int? qualityLackingTypeId;
  late String? qualityLackingTypeName;
  late String? lackContentName;
  late int? lackingTypeId;
  late String? lackingTypeName;
  late int? tertiaryMediaId;
  late String? tertiaryMediaName;
  late bool immediate;
  late int improvementDeadline;
  late List<Map<String, dynamic>>? photos;

  Lack.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    roundId = json['roundId'];
    uuid = json['uuid'];
    location = json['location'];
    qualityLackingTypeId = json['qualityLackingTypeId'];
    qualityLackingTypeName = json['qualityLackingTypeName'];
    lackContentName = json['lackContentName'];
    lackingTypeId = json['lackingTypeId'];
    lackingTypeName = json['lackingTypeName'];
    tertiaryMediaId = json['tertiaryMediaId'];
    tertiaryMediaName = json['tertiaryMediaName'];
    immediate = json['immediate'];
    improvementDeadline = json['improvementDeadline'];
    photos = json['photos'] != null ? List.castFrom(json['photos']) : [];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['roundId'] = roundId;
    data['uuid'] = uuid;
    data['location'] = location;
    data['qualityLackingTypeId'] = qualityLackingTypeId;
    data['qualityLackingTypeName'] = qualityLackingTypeName;
    data['lackContentName'] = lackContentName;
    data['lackingTypeId'] = lackingTypeId;
    data['lackingTypeName'] = lackingTypeName;
    data['tertiaryMediaId'] = tertiaryMediaId;
    data['tertiaryMediaName'] = tertiaryMediaName;
    data['immediate'] = immediate;
    data['improvementDeadline'] = improvementDeadline;
    data['photos'] = photos;
    return data;
  }
}
