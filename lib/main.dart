import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:tycg/configs/app_colors.dart';
import 'package:tycg/configs/config.dart';
import 'package:tycg/provider/lack_provider.dart';
import 'package:tycg/provider/operation_provider.dart';
import 'package:tycg/routes.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:app_links/app_links.dart';
import 'package:tycg/utils/hive_box.dart';
import 'package:tycg/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:tycg/utils/http_service.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 初始化Hive
  await Hive.initFlutter();
  await Hive.openBox(BOX_APPLICATION_STATE);
  await Hive.openBox(BOX_AUTH_CODE);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;

  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
    FlutterNativeSplash.remove();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    Hive.close();
    super.dispose();
  }

  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      //檢查application 狀態
      var box = await HiveBox.openBox(BOX_APPLICATION_STATE);
      String? state = box.get('state');
      if (state == null || state == 'UNAUTHENTICATED') {
        return;
      }
      var tokenBox = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
      String? accessToken = await tokenBox.get(ACCESS_TOKEN);

      ///檢查token到期時間
      if (accessToken == null) {
        return;
      }
      DateTime expirationDate = JwtDecoder.getExpirationDate(accessToken);

      var outOfDate = expirationDate.add(const Duration(days: -1));

      if (DateTime.now().isAfter(outOfDate)) {
        HttpService().refreshToken();
      }
    }
  }

  Future<void> initDeepLinks() async {
    //開啟HiveBox認證資訊
    var authBox = await HiveBox.openBox(BOX_AUTH_CODE);
    String? authCode = authBox.get('code');
    //authCode = Box裡是否存有Code
    debugPrint('Code為: $authCode');
    //取得舊有Code
    _appLinks = AppLinks();
    final appLink = await _appLinks.getInitialAppLink();
    debugPrint('appLink $appLink');
    //如果不是null，有code的話直接覆蓋
    if (appLink != null) {
      final appCode = appLink.queryParameters['code'];
      if (appCode != null) {
        authBox.put('code', appCode);
      }
    }

    //監聽Code可以覆蓋原本的Code
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      debugPrint('監聽到的深度連結: $uri');
      //點擊連結拿到的code
      final linkCode = uri.queryParameters['code'];
      if (linkCode != null) {
        authBox.put('code', linkCode);
        debugPrint('動畫頁 $linkCode');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
              create: (context) => AuthProvider()),
          ChangeNotifierProvider<OperationProvider>(
              create: (context) => OperationProvider()),
          ChangeNotifierProvider<LackProvider>(
              create: (context) => LackProvider())
        ],
        child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            color: sWhite,
            title: '新工巡檢雲',
            theme: ThemeData(
                textTheme:
                    Theme.of(context).textTheme.apply(displayColor: sBlack),
                scaffoldBackgroundColor: sLightGrey,
                primarySwatch: Colors.blue,
                platform: TargetPlatform.iOS),
            routerConfig: routes));
  }
}
