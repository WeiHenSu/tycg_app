import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tycg/configs/config.dart';
import 'package:tycg/models/lack_data.dart';
import 'package:tycg/models/round_data.dart';
import 'package:tycg/utils/hive_box.dart';
import 'package:tycg/utils/http_service.dart';

class AuthProvider with ChangeNotifier {
  RoundData? _roundData;
  RoundData? get roundData => _roundData;

  DateTime? _updateTime;
  DateTime? get updateTime => _updateTime;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  setLoading(value) {
    _isLoading = value;
    notifyListeners();
  }

  Future isCodeValid(String code) async {
    try {
      HttpService client = HttpService();
      var response = await client.post('/api/account/app/$code');
      if (response.statusCode == 200) {
        var tokenData = response.data;
        var box = await HiveBox.openBox(BOX_AUTH_CODE);
        box.put('code', code);
        saveAuthorize(tokenData['accessToken'], tokenData['refreshToken']);
        await getRoundInfo(tokenData['roundId'].toString());
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      // 401跳回未授權,並清除登入資料
      if (e.response?.statusCode == 401) {
        debugPrint('e $e');
        await setUnauthorized();
        notifyListeners();
      }
      return false;
    }
  }

  Future getRoundInfo(String id) async {
    try {
      HttpService client = HttpService();
      var response = await client.get('/api/round/app/$id');
      if (response.statusCode == 200) {
        var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
        box.put(ROUND_DATA, jsonEncode(response.data));
        _roundData = RoundData.fromJson(response.data);
        notifyListeners();
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await setUnauthorized();
        notifyListeners();
      }
    }
  }

  Future loadRoundInfo() async {
    var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
    var data = box.get(ROUND_DATA);
    if (data != null) {
      Map<String, dynamic> roundMap = jsonDecode(data);
      _roundData = RoundData.fromJson(roundMap);

      notifyListeners();
    }
  }

  Future saveUpdateTime() async {
    DateTime updateTime = DateTime.now();
    debugPrint('最後更新時間：$updateTime');
    var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
    box.put(LAST_UPDATETIME, updateTime);
    _updateTime = updateTime;
    notifyListeners();
  }

  Future<bool> checkState() async {
    var box = await HiveBox.openBox(BOX_APPLICATION_STATE);
    String? state = box.get('state');
    if (state == 'AUTHENTICATED') {
      return true;
    } else if (state == 'UNAUTHENTICATED') {
      return false;
    } else {
      return false;
    }
  }

  Future saveAuthorize(String accessToken, String refreshToken) async {
    var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
    box.put(ACCESS_TOKEN, accessToken);
    box.put(REFRESH_TOKEN, refreshToken);
    box = await HiveBox.openBox(BOX_APPLICATION_STATE);
    box.put('state', 'AUTHENTICATED');
  }

  Future setUnauthorized() async {
    var stateBox = await HiveBox.openBox(BOX_APPLICATION_STATE);
    stateBox.put('state', 'UNAUTHENTICATED');
    var box = await HiveBox.openBox(BOX_AUTH_CODE);
    box.put('code', null);
  }
}
