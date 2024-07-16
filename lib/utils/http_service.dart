import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tycg/configs/config.dart';
import 'package:tycg/globals.dart';
import 'package:tycg/utils/get_device_info.dart';

import 'hive_box.dart';

class HttpService {
  late Dio _dio;

  HttpService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: BASE_URL,
      ),
    );

    initializeInterceptors();
  }

  Future<Response> get(String path) async {
    Response response;
    try {
      var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
      String? authToken = await box.get(ACCESS_TOKEN);

      response = await _dio.request(
        path,
        options: Options(
          method: "GET",
          headers: {HttpHeaders.authorizationHeader: 'Bearer $authToken'},
          contentType: Headers.jsonContentType,
        ),
      );
      return response;
    } on DioException {
      // if (e.response?.statusCode == 401) {
      //   bool result = await refreshToken();
      //   if (result) {
      //     return await get(path);
      //   }
      // }
      rethrow;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
  }) async {
    return _request(path: path, method: 'post', data: data);
  }

  Future<Response> put(
    String path, {
    dynamic data,
  }) async {
    return _request(path: path, method: 'put', data: data);
  }

  Future<Response> delete({
    required String path,
  }) async {
    return _request(path: path, method: 'delete');
  }

  Future<Response> _request({
    required String path,
    required String method,
    dynamic data,
  }) async {
    Response response;

    try {
      var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
      String? authToken = await box.get(ACCESS_TOKEN);

      response = await _dio.request(
        path,
        data: data,
        options: Options(
          method: method,
          headers: {HttpHeaders.authorizationHeader: 'Bearer $authToken'},
          contentType: Headers.jsonContentType,
        ),
      );
    } on DioException {
      rethrow;
    }
    return response;
  }

  Future<bool> refreshToken() async {
    try {
      if (Globals.refreshTokening == true) {
        return false;
      }

      Globals.refreshTokening = true;

      var securityBox = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
      var accessToken = securityBox.get(ACCESS_TOKEN);
      var refreshToken = securityBox.get(REFRESH_TOKEN);

      Response response = await _dio.post(
        '/api/token-refresh',
        data: {
          ACCESS_TOKEN: accessToken,
          REFRESH_TOKEN: refreshToken,
        },
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );
      if (response.statusCode == HttpStatus.ok) {
        var data = jsonDecode(response.toString());
        securityBox.put(ACCESS_TOKEN, data['access_token']);
        securityBox.put(REFRESH_TOKEN, data['refresh_token']);

        return true;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        var appBox = await HiveBox.openBox(BOX_APPLICATION_STATE);
        appBox.put('state', 'UNAUTHENTICATED');
      }
    } finally {
      Globals.refreshTokening = false;
    }
    return false;
  }

  ///初始化作業
  initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint("${options.method} ${options.path}");

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }
}
