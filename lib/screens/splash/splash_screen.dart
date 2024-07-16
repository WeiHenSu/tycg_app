import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:tycg/configs/app_colors.dart';
import 'package:tycg/configs/config.dart';
import 'package:tycg/provider/auth_provider.dart';
import 'package:tycg/provider/lack_provider.dart';
import 'package:tycg/provider/operation_provider.dart';
import 'package:tycg/utils/hive_box.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<_SplashScreenState> globalKey =
      GlobalKey<_SplashScreenState>();
  late AnimationController _splashController;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _subscription;

  ConnectivityResult? _connectivityStatus;

  @override
  void initState() {
    _splashController = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          //有code進home，沒code進login登入
          getCode().then(
            (code) {
              if (code == null) {
                context.pushReplacementNamed('login');
              } else {
                checkCode(code).then((value) => {
                      if (value)
                        {context.pushReplacementNamed('home')}
                      else
                        {
                          context.pushReplacementNamed('login', extra: true),
                        }
                    });
              }
            },
          );
        }
      });

    super.initState();
    initConnectivity();
    _subscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      debugPrint('Couldn\'t check connectivity status $e');
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectivityStatus = result;
    });
  }

  //驗證Code是否有效
  Future<bool> checkCode(String code) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setLoading(true);
    // final cxt = globalKey.currentContext;

    //判斷連線狀態
    if (_connectivityStatus == ConnectivityResult.none) {
      debugPrint('沒網路連線 取舊資料');
    } else {
      //連線成功則驗證Code
      final valid = await authProvider.isCodeValid(code);
      debugPrint('valid $valid');

      if (!valid) {
        //狀態顯示未驗證，去登入
        authProvider.setLoading(false);
        // if (cxt != null && cxt.mounted) {
        //   cxt.pushReplacementNamed('login');
        // }
        return false;
      } else {
        //通過，讀資料
        getData(authProvider);
        return true;
      }
    }

    return false;
  }

  //取得資料庫資料
  Future<void> getData(AuthProvider authProvider) async {
    try {
      var lackProvider = Provider.of<LackProvider>(context, listen: false);
      var operProvider = Provider.of<OperationProvider>(context, listen: false);
      var roundId = 0;
      if (authProvider.roundData != null) {
        roundId = authProvider.roundData!.id;
      }
      debugPrint('讀取roundId $roundId');
      await Future.wait([
        lackProvider.fetch(roundId),
        operProvider.fetch(),
        lackProvider.getLackType(),
        lackProvider.getTertiaryMedia(),
        lackProvider.getLackContent(),
        operProvider.loadOperationInfo(),
        lackProvider.loadLackInfo(),
        authProvider.saveUpdateTime(),
      ]);
      authProvider.setLoading(false);
      debugPrint('資料讀取完畢');
    } catch (e) {
      debugPrint('e $e');
    }
  }

  @override
  void dispose() {
    _splashController.dispose();
    super.dispose();
  }

  Future<String?> getCode() async {
    var authBox = await HiveBox.openBox(BOX_AUTH_CODE);
    String? code = authBox.get('code');
    debugPrint('動畫頁 $code');
    return code;
  }

  @override
  Widget build(BuildContext context) {
    return LottieAnimate(
      frameBuilder: (context, child, composition) {
        return Transform.scale(
          scale: 1,
          child: Container(
            color: sWhite,
            child: child,
          ),
        );
      },
    );
  }
}

class LottieAnimate extends StatelessWidget {
  final Widget Function(
          BuildContext context, Widget child, LottieComposition? composition)
      frameBuilder;
  const LottieAnimate({Key? key, required this.frameBuilder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _SplashScreenState? state = context.findAncestorStateOfType();

    return Lottie.asset('assets/lottie/splash.json',
        fit: BoxFit.cover,
        repeat: false,
        controller: state!._splashController, onLoaded: (composition) {
      state._splashController
        ..duration = composition.duration
        ..forward();
    }, frameBuilder: frameBuilder);
  }
}
