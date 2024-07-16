import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:tycg/configs/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:tycg/configs/config.dart';
import 'package:tycg/provider/auth_provider.dart';
import 'package:tycg/utils/hive_box.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, required this.extra}) : super(key: key);

  final bool? extra;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<_LoginScreenState> globalKey = GlobalKey<_LoginScreenState>();
  late TextEditingController _loginController;

  @override
  void initState() {
    super.initState();
    _loginController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _loginController.dispose();
  }

  Future<void> showAlertDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          "登入錯誤",
          style: TextStyle(fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.remove_circle_outline,
              color: Colors.red[400],
              size: 80.0,
            ),
            const Text('巡檢碼錯誤或不存在。'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('關閉'),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.extra == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlertDialog(context);
      });
    }
    return Scaffold(
      key: globalKey,
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          return LoadingOverlay(
            isLoading: auth.isLoading,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height,
                ),
                child: SafeArea(
                  child: Container(
                    height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/login.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              const SizedBox(
                                height: 230,
                              ),
                              Image.asset(
                                "assets/images/logo.png",
                                width: double.infinity,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(
                                height: 55,
                              ),
                              CupertinoTextField(
                                controller: _loginController,
                                padding: const EdgeInsets.all(14),
                                decoration: const BoxDecoration(
                                  color: sLightGrey,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                                placeholder: '輸入巡檢碼',
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: sPurple,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(18)),
                                ),
                                child: CupertinoButton(
                                  onPressed: () async {
                                    var authBox =
                                        await HiveBox.openBox(BOX_AUTH_CODE);
                                    authBox.put('code', _loginController.text);
                                    final cxt = globalKey.currentContext;

                                    if (cxt != null && cxt.mounted) {
                                      cxt.pushReplacementNamed('search');
                                    }

                                    // auth.setLoading(true);
                                    // bool valid = await auth
                                    //     .isCodeValid(_loginController.text);

                                    // auth.setLoading(false);
                                    // if (valid) {
                                    //   debugPrint('valid $valid');
                                    //   if (cxt != null && cxt.mounted) {
                                    //     cxt.pushReplacementNamed('search');
                                    //   }
                                    // } else {
                                    //   if (cxt != null && cxt.mounted) {
                                    //     ScaffoldMessenger.of(cxt)
                                    //         .showSnackBar(const SnackBar(
                                    //       content: Text('驗證碼錯誤'),
                                    //     ));
                                    //     debugPrint("失敗");
                                    //   }
                                    // }
                                  },
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(color: sWhite),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 55,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
