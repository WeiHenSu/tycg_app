import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tycg/configs/app_colors.dart';
import 'package:tycg/configs/config.dart';
import 'package:tycg/models/lack_data.dart';
import 'package:tycg/models/lackcontent_data.dart';
import 'package:tycg/models/lacktype_data.dart';
import 'package:tycg/models/tertiarymedia_data.dart';
import 'package:tycg/provider/lack_provider.dart';
import 'package:tycg/utils/hive_box.dart';
import 'package:tycg/widgets/photo_viewer.dart';
import 'package:go_router/go_router.dart';

class LackEditScreen extends StatefulWidget {
  const LackEditScreen({Key? key, required this.extra}) : super(key: key);

  final Lack? extra;
  @override
  State<LackEditScreen> createState() => _LackEditScreenState();
}

class _LackEditScreenState extends State<LackEditScreen> {
  late bool isSafty = false;
  late bool isImmediate = false;

  late LackProvider lackProvider;

  late int? lackId;
  late String? lackUUID;
  late TextEditingController locationController;
  late TextEditingController deadlineController;

  late List<bool> immediate = [false, false];

  final List<Widget> immediateText = <Widget>[
    const Text('是'),
    const Text('否'),
  ];

  final List<bool> improvementDeadline = [false, false, false];

  final List<Widget> improvementText = <Widget>[
    const Text('3'),
    const Text('7'),
    const Text('15'),
  ];

  //缺失類型
  late List<LackType>? lackTypes = [];

  //媒介物
  late List<TertiaryMedia>? tertiaryMedias = [];

  //缺失內容
  final List<LackContent> lackContents = [];

  bool isCustom = false;

  //限期改善自訂天數切換
  void _visibilityText(bool visibility) {
    setState(() {
      isCustom = visibility;
    });
  }

  // 尋找缺失內容ID
  LackContent? findById(List<dynamic> list, int id) {
    for (var item in list) {
      if (item['id'] == id) {
        return LackContent.fromJson(item);
      } else if (item['childList'] != null && item['childList'].isNotEmpty) {
        var result = findById(item['childList'], id);
        if (result != null) {
          return result;
        }
      }
    }
    return null;
  }

  //儲存資料 右下打勾按鈕
  Future<void> updateData(Lack? item) async {
    if (item != null) {
      var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
      var data = box.get(LACK_DATA);
      List<dynamic> lackList = jsonDecode(data);
      debugPrint('boxData $lackList');

      if (lackUUID != "fromWeb") {
        var index =
            lackList.indexWhere((element) => element['uuid'] == lackUUID);
        if (index != -1) {
          var find =
              lackList.firstWhere((element) => element['uuid'] == lackUUID);

          if (find != null) {
            debugPrint('find ${item.lackingTypeId}');

            find['location'] = item.location;
            find['qualityLackingTypeId'] = item.qualityLackingTypeId;
            find['qualityLackingTypeName'] = item.qualityLackingTypeName;
            find['lackingTypeId'] = item.lackingTypeId;
            find['lackingTypeName'] = item.lackingTypeName;
            find['tertiaryMediaId'] = item.tertiaryMediaId;
            find['tertiaryMediaName'] = item.tertiaryMediaName;
            find['immediate'] = item.immediate;
            find['improvementDeadline'] = item.improvementDeadline;
          }
        } else {
          debugPrint('拍照');
          lackList.add(item);
        }
      } else {
        var find = lackList.firstWhere((element) => element['id'] == lackId);

        if (find != null) {
          debugPrint('find ${item.lackingTypeId}');

          find['location'] = item.location;
          find['qualityLackingTypeId'] = item.qualityLackingTypeId;
          find['qualityLackingTypeName'] = item.qualityLackingTypeName;
          find['lackingTypeId'] = item.lackingTypeId;
          find['lackingTypeName'] = item.lackingTypeName;
          find['tertiaryMediaId'] = item.tertiaryMediaId;
          find['tertiaryMediaName'] = item.tertiaryMediaName;
          find['immediate'] = item.immediate;
          find['improvementDeadline'] = item.improvementDeadline;
        } else {
          debugPrint('沒找到東西');
        }
      }

      var newData = jsonEncode(lackList);
      box.put(LACK_DATA, newData);
      debugPrint('更新後: $newData');
    }
  }

  //pop後更新介面
  void updateUI(List<dynamic> list, item) async {
    var extra = widget.extra;
    if (extra != null) {
      var result = list.firstWhere((element) => element['id'] == item['value'],
          orElse: () => null);
      debugPrint('result $result');

      //比對看是哪個List
      var listSet = list.map((element) => element['name']).toSet();
      var lackType = await getLackTypes();
      var lackTypeSet = lackType.map((element) => element['name']).toSet();

      var tertiaryMedia = await getTertiaryMedias();
      var tertiaryMediaSet =
          tertiaryMedia.map((element) => element['name']).toSet();

      if (lackTypeSet.containsAll(listSet) &&
          listSet.containsAll(lackTypeSet)) {
        extra.lackingTypeId = result['id'];
        extra.lackingTypeName = result['code'] + " - " + result['name'];
        debugPrint('LackType更新 ${extra.lackingTypeId}');
      }
      if (tertiaryMediaSet.containsAll(listSet) &&
          listSet.containsAll(tertiaryMediaSet)) {
        extra.tertiaryMediaId = result['id'];
        extra.tertiaryMediaName = result['name'];
        debugPrint('TertiaryMedia更新 $extra');
      }
    }
  }

  //TODO: 改品質更新缺失內容
  void updateContent(List<dynamic> list, item) async {
    var extra = widget.extra;

    if (extra != null) {
      var lackContent = findById(list, item['value']['id']);
      if (lackContent != null) {
        extra.qualityLackingTypeName = lackContent.name;
        extra.qualityLackingTypeId = lackContent.id;
      }
      extra.lackingTypeId = null;
      extra.tertiaryMediaId = null;
      debugPrint('LackContent更新 ${extra.qualityLackingTypeId}');
      debugPrint('isSafty ${item['value']['isSafty']}');
      isSafty = item['value']['isSafty'];

      debugPrint('isImmediate ${item['value']['isImmediate']}');
      isImmediate = item['value']['isImmediate'];
      if (isImmediate) {
        immediate[0] = true;
        immediate[1] = false;
      } else {
        immediate[0] = false;
        immediate[1] = true;
      }
    }
  }

  //進選單頁
  void entrySelect(list, title) {
    if (title != "缺失內容") {
      context.pushNamed('lack-select', extra: {'list': list}).then((value) {
        debugPrint('value $value');
        updateUI(list, value);
      });
    } else {
      context.pushNamed('inner-select', extra: {'list': list}).then((value) {
        debugPrint('value $value');
        updateContent(list, value);
      });
    }
  }

  Future<List<dynamic>> getLackTypes() async {
    var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
    var data = box.get(LACKTYPE_DATA);
    List<dynamic>? dataList = jsonDecode(data);
    return dataList ?? [];
  }

  Future<List<dynamic>> getTertiaryMedias() async {
    var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
    var data = box.get(TERTIARY_DATA);
    List<dynamic>? dataList = jsonDecode(data);
    return dataList ?? [];
  }

  Future<List<dynamic>> getLackContent() async {
    var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
    var data = box.get(LACKCONTENT_DATA);
    List<dynamic>? dataList = jsonDecode(data);
    return dataList ?? [];
  }

  checkSafety(Lack? parent) async {
    var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
    var data = box.get(LACKCONTENT_DATA);
    List<dynamic> dataList = jsonDecode(data);
    setState(() {
      if (parent != null) {
        lackId = parent.id;
        lackUUID = parent.uuid;
        if (parent.qualityLackingTypeId != null) {
          var lackContent = findById(dataList, parent.qualityLackingTypeId!);
          if (lackContent != null) {
            debugPrint('已更新內容');
            if (lackContent.isSafty == true) {
              isSafty = true;
            } else {
              isSafty = false;
            }
            if (lackContent.isImmediate == true) {
              isImmediate = true;
            } else {
              isImmediate = false;
            }
          }
        }
      }
    });
  }

  Future<void> initializeData(Lack? parent) async {
    await checkSafety(parent);
  }

  @override
  void initState() {
    super.initState();
    var parent = widget.extra;
    initializeData(parent);
    locationController = TextEditingController();
    locationController.text = parent?.location ?? "";
    locationController.selection = TextSelection.fromPosition(
      TextPosition(offset: locationController.text.length),
    );

    deadlineController = TextEditingController();
    deadlineController.text = parent?.improvementDeadline.toString() ?? "";
    deadlineController.selection = TextSelection.fromPosition(
      TextPosition(offset: deadlineController.text.length),
    );

    //立即性初始化
    immediate.asMap().forEach((index, item) {
      if (parent?.immediate == true) {
        immediate[0] = true;
      }
      if (parent?.immediate == false) {
        immediate[1] = true;
      }
    });

    //限期改善天數初始化
    improvementDeadline.asMap().forEach((index, item) {
      if (parent?.improvementDeadline == 3) {
        improvementDeadline[0] = true;
      } else if (parent?.improvementDeadline == 7) {
        improvementDeadline[1] = true;
      } else if (parent?.improvementDeadline == 15) {
        improvementDeadline[2] = true;
      } else {
        isCustom = true;
      }
    });
  }

  @override
  void dispose() {
    locationController.dispose();
    deadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.extra;

    return Scaffold(
      backgroundColor: sWhite,
      body: LayoutBuilder(builder: (context, constraints) {
        return SafeArea(
            child: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                stretch: true,
                backgroundColor: sWhite,
                forceElevated: false,
                elevation: 0,
                leading: SizedBox(
                  width: 10,
                  height: 10,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.black.withOpacity(0.1),
                      padding: EdgeInsets.zero,
                      elevation: 1,
                    ),
                    onPressed: () {
                      context.pop();
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: sWhite,
                    ),
                  ),
                ),
                flexibleSpace: Stack(
                  children: [
                    _buildBackground(item),
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
                        const Text(
                          '缺失內容填寫',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: sBlack),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(
                          color: sPurple,
                          thickness: 2,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        _buildFormArea(constraints, item)
                      ]),
                ),
              )
            ],
          ),
        ));
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          updateData(item);
          context.pop();
        },
        backgroundColor: sPurple,
        shape: const CircleBorder(),
        child: const Icon(Icons.done, color: sWhite),
      ),
    );
  }

  //上方背景圖片
  Widget _buildBackground(Lack? item) {
    return Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: SizedBox(
            child: GestureDetector(
          onTap: () {
            item?.id != 0
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PhotoViewScreen(
                              imageProvider: NetworkImage((item
                                          ?.photos?.isNotEmpty ??
                                      false)
                                  ? BASE_URL +
                                      ROUND_ASSETS +
                                      item!.photos![0]['filename']
                                  : '$BASE_URL${CONSTRUCTION_ASSETS}preview.jpg'),
                            )),
                  )
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PhotoViewScreen(
                              imageProvider: FileImage(
                                  File(item?.photos?[0]['path'] ?? '')),
                            )),
                  );
          },
          child: item?.id != 0
              ? CachedNetworkImage(
                  imageUrl: ((item?.photos?.isNotEmpty ?? false)
                      ? BASE_URL + ROUND_ASSETS + item!.photos![0]['filename']
                      : '$BASE_URL${CONSTRUCTION_ASSETS}preview.jpg'),
                  width: 300.0,
                  height: 300.0,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error))
              : Image.file(
                  (File.fromUri(Uri.file(item?.photos?[0]['path'] ?? ''))),
                  width: 300.0,
                  height: 300.0,
                  fit: BoxFit.cover,
                ),
        )));
  }

  //白底區塊
  Widget _buildWhiteBgArea() {
    return Positioned(
        bottom: -1,
        left: 0,
        right: 0,
        child: Container(
          height: 20,
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

  // 表單區塊
  Widget _buildFormArea(BoxConstraints constraints, Lack? item) {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: locationController,
            decoration: const InputDecoration(
              labelText: "缺失地點",
              labelStyle: TextStyle(fontSize: 18),
              hintText: "請輸入缺失地點",
            ),
            onChanged: (value) {
              item?.location = value;
            },
          ),
          const SizedBox(
            height: 15,
          ),
          FutureBuilder<List<dynamic>>(
            future: getLackContent(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return _buildButton(
                    '缺失內容', snapshot.data, item?.qualityLackingTypeId);
              }
            },
          ),
          if (isSafty) ...[
            const SizedBox(
              height: 10,
            ),
            FutureBuilder<List<dynamic>>(
              future: getLackTypes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return _buildButton(
                      '危害類型', snapshot.data, item?.lackingTypeId);
                }
              },
            ),
            const SizedBox(
              height: 10,
            ),
            FutureBuilder<List<dynamic>>(
              future: getTertiaryMedias(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return _buildButton(
                      '媒介物', snapshot.data, item?.tertiaryMediaId);
                }
              },
            ),
            const SizedBox(
              height: 10,
            )
          ],
          SizedBox(
            width: constraints.maxWidth,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('立即性', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 5),
                  ToggleButtons(
                    onPressed: (int index) {
                      setState(() {
                        for (int i = 0; i < immediate.length; i++) {
                          immediate[i] = i == index;
                        }
                      });
                      if (item != null) {
                        if (index == 0) {
                          item.immediate = true;
                        } else if (index == 1) {
                          item.immediate = false;
                        }
                      }
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    selectedBorderColor: sPurple,
                    selectedColor: sWhite,
                    fillColor: sPurple,
                    color: sPurple,
                    constraints: BoxConstraints(
                      minHeight: 40.0,
                      minWidth: constraints.maxWidth / 5,
                    ),
                    isSelected: immediate,
                    children: immediateText,
                  ),
                ]),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: constraints.maxWidth,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('限期改善', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 5),
                  ToggleButtons(
                    onPressed: (int index) {
                      setState(() {
                        for (int i = 0; i < improvementDeadline.length; i++) {
                          improvementDeadline[i] = (i == index);
                        }
                        _visibilityText(false);
                      });
                      if (item != null) {
                        debugPrint('index $index');
                        if (index == 0) {
                          item.improvementDeadline = 3;
                        } else if (index == 1) {
                          item.improvementDeadline = 7;
                        } else if (index == 2) {
                          item.improvementDeadline = 15;
                        }
                      }
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    selectedBorderColor: isCustom ? sGrey : sPurple,
                    selectedColor: sWhite,
                    fillColor: isCustom ? sGrey : sPurple,
                    color: isCustom ? sGrey : sPurple,
                    constraints: BoxConstraints(
                      minHeight: 40.0,
                      minWidth: constraints.maxWidth / 5,
                    ),
                    isSelected: improvementDeadline,
                    children: improvementText,
                  ),
                ]),
          ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            width: constraints.maxWidth,
            child: Row(children: [
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(isCustom ? sPurple : sWhite),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)))),
                onPressed: () {
                  setState(() {
                    _visibilityText(true);
                  });
                },
                child: Text(
                  "自訂天數",
                  style: TextStyle(color: isCustom ? sWhite : sPurple),
                ),
              ),
              isCustom
                  ? Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Column(children: [
                            TextFormField(
                              controller: deadlineController,
                              decoration: const InputDecoration(
                                  hintText: "請輸入自訂天數",
                                  hintStyle: TextStyle(fontSize: 16.0)),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                int? intValue = int.tryParse(value);
                                if (intValue != null) {
                                  item?.improvementDeadline = intValue;
                                } else {
                                  debugPrint('自訂天數錯誤');
                                }
                              },
                            ),
                            const SizedBox(height: 10)
                          ])))
                  : const SizedBox(),
            ]),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    ));
  }

  Widget _buildButton(String title, List<dynamic>? list, int? id) {
    debugPrint('idid $id');
    String buttonValue = "請選擇$title";
    if (list == null || list.isEmpty || id == null) {
      buttonValue = "請選擇$title";
    } else {
      if (title != "缺失內容") {
        dynamic element = list.firstWhere((element) => element['id'] == id,
            orElse: () => null);
        if (element != null && element['code'] != null) {
          buttonValue = element['code'] + ' - ' + element['name'];
        } else {
          buttonValue = element['name'];
        }
      } else {
        var lackContent = findById(list, id);
        if (lackContent != null) {
          buttonValue = "${lackContent.code} - ${lackContent.name}";
        }
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      const SizedBox(
        height: 10,
      ),
      Row(
        children: [
          Expanded(
              flex: 1,
              child: Stack(alignment: Alignment.center, children: [
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      entrySelect(list, title);
                    },
                    style: ButtonStyle(
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0))),
                        side: const MaterialStatePropertyAll(
                            BorderSide(color: sLightGrey))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        buttonValue,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                    right: 15,
                    child: Icon(
                      Icons.keyboard_arrow_right,
                      color: sPurple,
                    ))
              ]))
        ],
      )
    ]);
  }
}
