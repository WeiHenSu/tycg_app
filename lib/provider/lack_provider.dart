import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:tycg/configs/config.dart';
import 'package:tycg/models/lack_data.dart';
import 'package:tycg/models/lackcontent_data.dart';
import 'package:tycg/models/lacktype_data.dart';
import 'package:tycg/models/tertiarymedia_data.dart';
import 'package:tycg/utils/hive_box.dart';
import 'package:tycg/utils/http_service.dart';

class LackProvider with ChangeNotifier {
  List<Lack>? _lackDatas;
  List<Lack>? get lackDatas => _lackDatas;

  List<LackType>? _lackTypes;
  List<LackType>? get lackTypes => _lackTypes;

  List<TertiaryMedia>? _tertiaryMedias;
  List<TertiaryMedia>? get tertiaryMedias => _tertiaryMedias;

  List<LackContent>? _lackContent;
  List<LackContent>? get lackContent => _lackContent;

  int? _lackCount;
  int? get lackCount => _lackCount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  setLoading(value) {
    _isLoading = value;
    notifyListeners();
  }

  Future fetch(int id) async {
    try {
      HttpService client = HttpService();
      var response = await client.get('/api/lacking/app/$id');

      if (response.statusCode == 200) {
        var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
        box.put(LACK_DATA, jsonEncode(response.data));
        _lackDatas = response.data
            ?.map((json) => Lack.fromJson(json))
            .cast<Lack>()
            .toList();
        _lackCount = _lackDatas?.length;
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
      //如果系統上沒缺失 要把資料清除
      var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
      box.put(LACK_DATA, []);
      _lackCount = 0;
    }
  }

  Future loadLackInfo() async {
    var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
    var data = box.get(LACK_DATA);
    if (data != null) {
      var lackList = jsonDecode(data);
      _lackDatas = lackList
          ?.map((json) => Lack.fromJson(json))
          .where((lack) => lack.uuid != 'delete')
          .cast<Lack>()
          .toList();
      _lackCount = _lackDatas?.length;
      notifyListeners();
    }
  }

  Future getLackType() async {
    try {
      HttpService client = HttpService();
      var response = await client.get('/api/lackingtype');

      if (response.statusCode == 200) {
        var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
        box.put(LACKTYPE_DATA, jsonEncode(response.data));
        _lackTypes = response.data
            ?.map((json) => LackType.fromJson(json))
            .cast<LackType>()
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future getTertiaryMedia() async {
    try {
      HttpService client = HttpService();
      var response = await client.get('/api/tertiarymedia');

      if (response.statusCode == 200) {
        var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
        box.put(TERTIARY_DATA, jsonEncode(response.data));
        _tertiaryMedias = response.data
            ?.map((json) => TertiaryMedia.fromJson(json))
            .cast<TertiaryMedia>()
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future getLackContent() async {
    try {
      HttpService client = HttpService();
      var response = await client.get('/api/qualitytype');

      if (response.statusCode == 200) {
        var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
        box.put(LACKCONTENT_DATA, jsonEncode(response.data));
        _lackContent = response.data
            ?.map((json) => LackContent.fromJson(json as Map<String, dynamic>))
            .cast<LackContent>()
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future updateLackCount() async {
    try {
      HttpService client = HttpService();
      var response = await client.get('/api/qualitytype');

      if (response.statusCode == 200) {
        var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
        box.put(LACKCONTENT_DATA, jsonEncode(response.data));
        _lackContent = response.data
            ?.map((json) => LackContent.fromJson(json as Map<String, dynamic>))
            .cast<LackContent>()
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future save(int id) async {
    try {
      //整包同時更新
      var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
      var lacks = box.get(LACK_DATA);
      List<dynamic> lackList = jsonDecode(lacks);
      debugPrint('lackList $lackList');
      HttpService client = HttpService();

      final results =
          await Stream.fromIterable(lackList).asyncMap((lack) async {
        debugPrint('lack ${lack['id']}');
        final map = {
          "id": lack['id'],
          "roundId": lack['roundId'],
          "uuid": lack['uuid'],
          "location": lack['location'],
          "lackContentId": lack['lackContentId'],
          "qualityLackingTypeId": lack['qualityLackingTypeId'],
          "lackingTypeId": lack['lackingTypeId'],
          "tertiaryMediaId": lack['tertiaryMediaId'],
          "immediate": lack['immediate'],
          "improvementDeadline": lack['improvementDeadline'],
          "photos": (lack['photos'] as List<dynamic>?)
                  ?.map((photo) => {
                        'id': photo['id'],
                        'filename': photo['filename'],
                      })
                  .toList() ??
              [],
        };
        final entity = jsonEncode(map);
        final contentMap = {'lacking': entity};
        final formData = FormData.fromMap(contentMap);
        debugPrint('formData $contentMap');

        if (map['id'] == 0) {
          debugPrint('hi');
          await for (final photo in Stream.fromIterable(lack['photos'] ?? [])) {
            final file = await MultipartFile.fromFile(
              photo['path'],
              filename: photo['filename'],
            );
            formData.files.add(MapEntry(photo['filename'], file));
          }
        }

        try {
          final response =
              await client.post('/api/lacking/app', data: formData);
          if (response.statusCode == 200) {
            debugPrint("缺失更新成功");
            fetch(id);
            return true;
          }
        } catch (e) {
          debugPrint(e.toString());
        }
        return false;
      }).toList();

      final allSuccessful = results.every((result) => result);
      notifyListeners();
      return allSuccessful;
    } catch (e) {
      debugPrint(e.toString());
      debugPrint("缺失更新失敗");
      return false;
    }
  }
}
