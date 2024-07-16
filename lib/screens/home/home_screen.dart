import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:tycg/configs/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tycg/configs/config.dart';
import 'package:tycg/models/round_data.dart';
import 'package:tycg/provider/auth_provider.dart';
import 'package:tycg/provider/lack_provider.dart';
import 'package:tycg/provider/operation_provider.dart';
import 'package:tycg/utils/hive_box.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _subscription;

  ConnectivityResult? _connectivityStatus;

  final GlobalKey<_HomeScreenState> globalKey = GlobalKey<_HomeScreenState>();
  final List options = [
    {
      "name": "作業項目",
      "icon": "assets/icons/operation.svg",
      "key": "operation",
    },
    {
      "name": "缺失項目",
      "icon": "assets/icons/lack.svg",
      "key": "lack",
    }
  ];

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _subscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sWhite,
      body: Consumer<AuthProvider>(builder: (context, auth, child) {
        return LoadingOverlay(
            isLoading: auth.isLoading,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return SafeArea(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints.expand(),
                      child: CustomScrollView(
                        slivers: [
                          SliverAppBar(
                            expandedHeight: 200.0,
                            pinned: true,
                            stretch: true,
                            backgroundColor: sWhite,
                            forceElevated: false,
                            elevation: 0,
                            leading: null,
                            flexibleSpace: Stack(
                              children: [
                                _buildBackground(auth),
                                _buildWhiteBgArea(),
                              ],
                            ),
                          ),
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // _buildNetWork(),
                                    // const SizedBox(
                                    //   height: 15,
                                    // ),
                                    Text(
                                      auth.isLoading
                                          ? '讀取中...'
                                          : '${auth.roundData?.constructionName}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: sBlack),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                      height: 25,
                                    ),
                                    const Divider(
                                      color: sPurple,
                                      thickness: 2,
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    _buildCardArea(),
                                  ]),
                            ),
                          )
                        ],
                      )));
            }));
      }),
    );
  }

  //網路連線狀態
  Widget _buildNetWork() {
    var status = '讀取中..';
    debugPrint('_connectivityStatus $_connectivityStatus');
    if (_connectivityStatus == ConnectivityResult.mobile) {
      status = '正在使用行動網路連線';
    } else if (_connectivityStatus == ConnectivityResult.wifi) {
      status = '正在使用 WIFI 連線';
    } else if (_connectivityStatus == ConnectivityResult.none) {
      status = '目前尚未與線上同步';
    }
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          '目前連線狀態: $status',
        ),
      ],
    );
  }

  //背景照片
  Widget _buildBackground(AuthProvider auth) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: CachedNetworkImage(
          imageUrl: ((auth.roundData?.constructionPhotos?.isNotEmpty ?? false)
              ? BASE_URL +
                  CONSTRUCTION_ASSETS +
                  auth.roundData!.constructionPhotos![0]['filename']
              : '$BASE_URL${CONSTRUCTION_ASSETS}preview.jpg'),
          width: 400.0,
          height: 300.0,
          fit: BoxFit.cover,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error)),
    );
  }

  //白色區塊
  Widget _buildWhiteBgArea() {
    return Positioned(
        bottom: -1,
        left: 0,
        right: 0,
        child: Container(
          height: 15,
          padding: const EdgeInsets.only(
            top: 0,
            bottom: 5,
            left: 8,
            right: 8,
          ),
          decoration: const BoxDecoration(
              color: sWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0),
              ),
              boxShadow: [
                BoxShadow(
                    color: sLightGrey,
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3))
              ]),
        ));
  }

  Widget _buildCardArea() {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: options.map((e) {
              int index = options.indexOf(e);
              return infoCard(options[index]);
            }).toList(),
          ),
        ],
      ),
    ));
  }

  Widget infoCard(Map item) {
    var lackProvider = Provider.of<LackProvider>(context, listen: false);
    var operProvider = Provider.of<OperationProvider>(context, listen: false);
    return SizedBox(
      height: 200.0,
      child: GestureDetector(
        onTap: () {
          context.pushNamed(item['key']).then((value) {
            lackProvider.loadLackInfo();
            operProvider.loadOperationInfo();
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
              color: sPurple, borderRadius: BorderRadius.circular(12.0)),
          padding: const EdgeInsets.all(16.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: SvgPicture.asset(item["icon"],
                      color: sWhite,
                      height: 35,
                      width: 35,
                      fit: BoxFit.scaleDown),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [_buildConsumer(item)],
                )
              ]),
        ),
      ),
    );
  }

  Widget _buildConsumer(Map item) {
    if (item['key'] == 'operation') {
      return Consumer<OperationProvider>(builder: (context, oper, child) {
        return oper.isLoading == false ||
                (oper.operationRisk == null || oper.operationNormal == null)
            ? Column(children: [
                Text(
                  "高風險 ${oper.operationRisk ?? "讀取中..."} 項",
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 26, color: sWhite),
                ),
                Text(
                  "一般性 ${oper.operationNormal ?? "讀取中..."} 項",
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 26, color: sWhite),
                )
              ])
            : const Text(
                "資料讀取中...",
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 26, color: sWhite),
              );
      });
    } else {
      return Consumer<LackProvider>(builder: (context, lack, child) {
        return lack.isLoading == false
            ? Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  "缺失數 ${lack.lackCount ?? "讀取中..."} 項",
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 26, color: sWhite),
                ),
              )
            : const Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: Text(
                  "資料讀取中...",
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 26, color: sWhite),
                ));
      });
    }
  }
}
