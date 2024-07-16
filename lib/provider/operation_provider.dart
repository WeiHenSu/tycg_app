import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:tycg/configs/config.dart';
import 'package:tycg/models/operation_data.dart';
import 'package:tycg/models/round_data.dart';
import 'package:tycg/utils/hive_box.dart';
import 'package:tycg/utils/http_service.dart';

class OperationProvider with ChangeNotifier {
  List<OperationItem>? _operationDatas;
  List<OperationItem>? get operationDatas => _operationDatas;

  int? _operationRisk;
  int? get operationRisk => _operationRisk;

  int? _operationNormal;
  int? get operationNormal => _operationNormal;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  setLoading(value) {
    _isLoading = value;
    notifyListeners();
  }

  Future fetch() async {
    try {
      HttpService client = HttpService();
      var response = await client.get('/api/operation');

      if (response.statusCode == 200) {
        var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
        box.put(OPERATION_DATA, jsonEncode(response.data));
        _operationDatas = response.data
            ?.map((json) => OperationItem.fromJson(json))
            .cast<OperationItem>()
            .toList();
        debugPrint("_operationData ${_operationDatas?[0].name}");
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future update(int id, List<int> list) async {
    try {
      HttpService client = HttpService();
      var response =
          await client.put('/api/round/app/operation/$id', data: list);

      if (response.statusCode == 200) {
        debugPrint("作業項目更新成功");
        var risk = 0;
        var normal = 0;
        for (var item in list) {
          _operationDatas?.forEach((element) {
            if (element.id == item) {
              if (element.type == 0) {
                risk++;
              } else if (element.type == 2) {
                normal++;
              }
            }
          });
        }
        _operationRisk = risk;
        _operationNormal = normal;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
      debugPrint("作業項目更新失敗");
      return false;
    }
  }

  Future loadOperationInfo() async {
    try {
      var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
      var operdata = box.get(OPERATION_DATA);

      if (operdata != null) {
        var operlist = jsonDecode(operdata);
        _operationDatas = operlist
            ?.map((json) => OperationItem.fromJson(json))
            .cast<OperationItem>()
            .toList();

        var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
        var data = box.get(ROUND_DATA);

        if (operlist != null) {
          Map<String, dynamic> roundMap = jsonDecode(data);

          var round = RoundData.fromJson(roundMap);

          var risk = 0;
          var normal = 0;
          if (round.operationCategoryIds != null) {
            round.operationCategoryIds?.forEach((item) {
              _operationDatas?.forEach((element) {
                if (element.id == item) {
                  if (element.type == 0) {
                    risk++;
                  } else if (element.type == 2) {
                    normal++;
                  }
                }
              });
            });
            if (round.operationCategoryIds!.isEmpty) {
              _operationRisk = 0;
              _operationNormal = 0;
            } else {
              _operationRisk = risk;
              _operationNormal = normal;
            }
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
