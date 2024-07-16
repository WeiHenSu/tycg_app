import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:tycg/configs/config.dart';

class HiveBox {
  static final HiveBox _instance = HiveBox._internal();

  factory HiveBox() => _instance;

  HiveBox._internal();

  static Future<Box> openBox(String name) async {
    var isExisted = await Hive.boxExists(name);
    var isOpened = Hive.isBoxOpen(name);
    if (isExisted && isOpened) {
      return Hive.box(name);
    }
    return await Hive.openBox(name);
  }

  static Future<Box> openSecureBox(String name) async {
    var isExisted = await Hive.boxExists(name);
    var isOpened = Hive.isBoxOpen(name);
    if (isExisted && isOpened) {
      return Hive.box(name);
    }

    const FlutterSecureStorage storage = FlutterSecureStorage();

    var containsEncryptionKey =
        await storage.containsKey(key: SECURE_STORAGE_KEY);
    String? storageKey = '';
    if (!containsEncryptionKey) {
      var key = Hive.generateSecureKey();

      await storage.write(key: SECURE_STORAGE_KEY, value: base64UrlEncode(key));
    }
    storageKey = await storage.read(key: SECURE_STORAGE_KEY);

    if (storageKey == null || storageKey.isEmpty) {
      var key = Hive.generateSecureKey();
      storageKey = base64UrlEncode(key);
      await storage.write(key: SECURE_STORAGE_KEY, value: storageKey);
    }
    return await Hive.openBox(name,
        encryptionCipher: HiveAesCipher(base64Url.decode(storageKey)));
  }

  static Future clearBoxes() async {
    var box = await openBox(BOX_CACHE);
    await box.clear();
  }
}
