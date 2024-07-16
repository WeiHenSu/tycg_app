import 'package:tycg/models/lack_data.dart';

class RoundData {
  RoundData({
    required this.id,
    required this.name,
    required this.constructionName,
    required this.constructionId,
    required this.committeeName,
    required this.committeeEmail,
    this.committeePhone,
    this.operationCategoryIds,
    required this.committeeCode,
    this.constructionPhotos,
    this.lackings,
  });
  late int id;
  late String name;
  late String constructionName;
  late String constructionId;
  late String committeeName;
  late String committeeEmail;
  late String? committeePhone;
  late List<int>? operationCategoryIds;
  late String committeeCode;
  late List<Map<String, dynamic>>? constructionPhotos;
  late List<Lack>? lackings;

  RoundData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'] ?? '';
    constructionName = json['constructionName'] ?? '';
    constructionId = json['constructionId'];
    committeeName = json['committeeName'] ?? '';
    committeeEmail = json['committeeEmail'] ?? '';
    committeePhone = json['committeePhone'] ?? '';
    operationCategoryIds = json['operationCategoryIds'] != null
        ? List.castFrom(json['operationCategoryIds'])
        : [];
    committeeCode = json['committeeCode'] ?? '';
    constructionPhotos = json['constructionPhotos'] != null
        ? List.castFrom(json['constructionPhotos'])
        : [];
    lackings = json['lackings'] != null
        ? (json['lackings'] as List<dynamic>)
            .map((item) => Lack.fromJson(item))
            .toList()
        : [];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['constructionName'] = constructionName;
    data['constructionId'] = constructionId;
    data['committeeName'] = committeeName;
    data['committeeEmail'] = committeeEmail;
    data['committeePhone'] = committeePhone;
    data['operationCategoryIds'] = operationCategoryIds;
    data['committeeCode'] = committeeCode;
    data['constructionPhotos'] = constructionPhotos;
    data['lackings'] = lackings;
    return data;
  }
}
