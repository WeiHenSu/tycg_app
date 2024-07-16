import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tycg/models/device_info.dart';

Future<DeviceInfo> getDevcieInfo() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  DeviceInfo device = DeviceInfo();

  try {
    if (Platform.isAndroid) {
      var build = await deviceInfo.androidInfo;
      device.version = build.version.release.toString();
      device.id = build.id; //UUID for Android
      device.model = "${build.brand} ${build.model}";
    } else if (Platform.isIOS) {
      var info = await deviceInfo.iosInfo;
      device.version = info.systemVersion;
      device.id = info.identifierForVendor.toString();
      device.model = info.utsname.machine;
    }
    debugPrint('${device.version}, ${device.id}, ${device.model}');
  } on PlatformException catch (e) {
    debugPrint('$e');
  }

  return device;
}
