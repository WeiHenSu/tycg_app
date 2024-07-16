import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:tycg/configs/app_colors.dart';
import 'package:tycg/configs/config.dart';
import 'package:tycg/models/lack_data.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:tycg/models/round_data.dart';
import 'package:tycg/provider/lack_provider.dart';
import 'package:tycg/screens/lack/widgets/fab.dart';
import 'package:tycg/utils/hive_box.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

class LackScreen extends StatefulWidget {
  const LackScreen({super.key});

  @override
  State<LackScreen> createState() => _LackScreenState();
}

class _LackScreenState extends State<LackScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<_LackScreenState> globalKey = GlobalKey<_LackScreenState>();

  late LackProvider lackProvider;
  late int roundId;

  late String? copied;

  //拍完後的路徑
  late File _image;

  final imagePicker = ImagePicker();

  late Box<dynamic> box;

  late Animation<double> _animation;
  late AnimationController _controller;

  Future getCameraImage(BuildContext context) async {
    final image = await imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        String uuid = const Uuid().v4();
        Map<String, dynamic> photoMap = {
          'id': uuid,
          'filename': '$uuid.jpg',
          'figcaption': null,
          'path': _image.path,
          'cover': null,
        };
        var list = Lack(
            id: 0,
            roundId: roundId,
            uuid: uuid,
            location: null,
            lackingTypeId: null,
            qualityLackingTypeId: null,
            tertiaryMediaId: null,
            immediate: false,
            improvementDeadline: 3,
            photos: [photoMap]);
        lackProvider.lackDatas?.add(list);

        var newData = jsonEncode(lackProvider.lackDatas);
        box.put(LACK_DATA, newData);
        debugPrint('newData $newData');
        context.pushNamed('lack-edit', extra: {'lack': list}).then((value) {
          lackProvider.loadLackInfo();
        });
      });
    }
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _controller);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      lackProvider = Provider.of<LackProvider>(context, listen: false);
      lackProvider.setLoading(true);
      box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
      var data = box.get(ROUND_DATA);
      Map<String, dynamic> roundMap = jsonDecode(data);
      var roundData = RoundData.fromJson(roundMap);
      roundId = roundData.id;
      lackProvider.loadLackInfo().then((_) {
        lackProvider.setLoading(false);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: globalKey,
        appBar: AppBar(
          backgroundColor: sPurple,
          title: const Text(
            "缺失項目",
            style: TextStyle(fontWeight: FontWeight.w600, color: sWhite),
          ),
          leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: sWhite,
              ),
              onPressed: () {
                context.pop();
              }),
          actions: [
            SizedBox(
              height: 33,
              child: ElevatedButton(
                  onPressed: () async {
                    final cxt = globalKey.currentContext;
                    lackProvider.setLoading(true);
                    bool check = await lackProvider.save(roundId);
                    if (check) {
                      lackProvider.setLoading(false);
                      if (cxt != null && cxt.mounted) {
                        ScaffoldMessenger.of(cxt).showSnackBar(const SnackBar(
                          content: Text("更新成功"),
                        ));
                      }
                    } else {
                      lackProvider.setLoading(false);
                      if (cxt != null && cxt.mounted) {
                        ScaffoldMessenger.of(cxt).showSnackBar(const SnackBar(
                          content: Text("更新失敗"),
                        ));
                      }
                    }
                  },
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(sYellow),
                    shape: MaterialStatePropertyAll(StadiumBorder()),
                  ),
                  child: const Text(
                    '上 傳',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: sWhite),
                  )),
            ),
            const SizedBox(
              width: 10,
            )
          ],
        ),
        backgroundColor: sWhite,
        body: Consumer<LackProvider>(builder: (context, lack, child) {
          return LoadingOverlay(
            isLoading: lack.isLoading,
            child: SafeArea(
              child: ConstrainedBox(
                constraints: const BoxConstraints.expand(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [_buildLackList(lack)],
                ),
              ),
            ),
          );
        }),
        floatingActionButton: ExpandedAnimationFab(
          items: [
            FabItem(
              "使用相機拍攝",
              Icons.camera_alt_outlined,
              onPress: () {
                _controller.reverse();
                getCameraImage(context);
              },
            ),
            FabItem(
              "選取相簿照片",
              Icons.photo_library_outlined,
              onPress: () {
                _controller.reverse();
                getCameraImage(context);
              },
            ),
          ],
          animation: _animation,
          onPress: () {
            if (_controller.isCompleted) {
              _controller.reverse();
            } else {
              _controller.forward();
            }
          },
        ));
  }

  Widget _buildLackList(LackProvider lackProvider) {
    List<Lack>? filteredLackDatas =
        lackProvider.lackDatas?.where((lack) => lack.uuid != 'delete').toList();

    return Expanded(
        child: ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      itemCount: filteredLackDatas?.length ?? 0,
      itemBuilder: (context, index) {
        return _buildLack(lackProvider, filteredLackDatas?[index], index);
      },
    ));
  }

  Widget _buildLack(LackProvider lackProvider, Lack? lack, int index) {
    return Padding(
        key: ValueKey(lack?.id),
        padding: const EdgeInsets.only(bottom: 5),
        child: Slidable(
            key: ValueKey(lack?.id),
            direction: Axis.horizontal,
            enabled: lackProvider.lackDatas!.length <= 1 ? false : true,
            endActionPane: ActionPane(
                motion: const BehindMotion(),
                extentRatio: 0.3,
                dismissible: DismissiblePane(
                  onDismissed: () {
                    final cxt = globalKey.currentContext;
                    lackProvider.setLoading(true);

                    setState(() {
                      if (lack != null) {
                        copied = lack.uuid;
                        lack.uuid = "delete";
                        debugPrint('刪除 ${lack.uuid}');
                        var newData = jsonEncode(lackProvider.lackDatas);
                        box.put(LACK_DATA, newData);
                      }
                      lackProvider.setLoading(false);
                    });
                    if (cxt != null && cxt.mounted) {
                      ScaffoldMessenger.of(cxt).showSnackBar(SnackBar(
                        content: const Text('移除缺失成功'),
                        action: SnackBarAction(
                          label: '復原',
                          onPressed: () {
                            setState(() {
                              if (copied != null && lack != null) {
                                lack.uuid = copied;
                                debugPrint('復原 $copied');
                                var newData =
                                    jsonEncode(lackProvider.lackDatas);
                                box.put(LACK_DATA, newData);
                              }
                            });
                            ScaffoldMessenger.of(cxt).showSnackBar(
                                const SnackBar(content: Text('復原成功')));
                          },
                        ),
                      ));
                    }
                  },
                ),
                children: [
                  SlidableAction(
                    flex: 1,
                    onPressed: (BuildContext context) {},
                    icon: Icons.delete,
                    label: "删除",
                    backgroundColor: sLightRed,
                    foregroundColor: sWhite,
                  ),
                ]),
            child: Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
                child: GestureDetector(
                  onTap: () {
                    context.pushNamed('lack-edit', extra: {'lack': lack}).then(
                        (value) {
                      lackProvider.loadLackInfo();
                    });
                  },
                  child: Card(
                      child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minHeight: 95, maxHeight: 150),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              bottomLeft: Radius.circular(8.0)),
                          child: lack?.id != 0
                              ? CachedNetworkImage(
                                  imageUrl: (lack?.photos?.isNotEmpty ?? false)
                                      ? BASE_URL +
                                          ROUND_ASSETS +
                                          lack!.photos![0]['filename']
                                      : '$BASE_URL${CONSTRUCTION_ASSETS}preview.jpg',
                                  width: 95.0,
                                  height: 110.0,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                )
                              : Image.file(
                                  (File.fromUri(Uri.file(
                                      lack?.photos?[0]['path'] ?? ''))),
                                  width: 95.0,
                                  height: 110.0,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0,
                                right: 18.0,
                                top: 10.0,
                                bottom: 10.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lack?.qualityLackingTypeName ?? "未填寫",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          "改善期限 ：",
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold,
                                              color: sGrey),
                                        ),
                                        Text(
                                          "${lack?.improvementDeadline} 天後",
                                          style: const TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold,
                                              color: sGrey),
                                          textAlign: TextAlign.start,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          "地點 ：",
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold,
                                              color: sGrey),
                                        ),
                                        Text(
                                          lack?.location ?? "未填寫",
                                          style: const TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold,
                                              color: sGrey),
                                          textAlign: TextAlign.start,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  lack?.immediate ?? false ? sLightRed : sTeal,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5.0)),
                          ),
                          child: Text(
                            lack?.immediate ?? false ? "立即性" : "一般性",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                              color:
                                  lack?.immediate ?? false ? sLightRed : sTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ))));
  }
}
