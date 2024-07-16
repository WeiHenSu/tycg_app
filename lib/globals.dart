import 'package:flutter/material.dart';

class Globals {
  static final Globals _instance = Globals._internal();
  static String authToken = '';
  static bool refreshTokening = false;
  factory Globals() {
    return _instance;
  }
  Globals._internal();
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
