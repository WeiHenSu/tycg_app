import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:tycg/configs/app_colors.dart';
import 'package:tycg/configs/config.dart';
import 'package:tycg/models/operation_data.dart';
import 'package:go_router/go_router.dart';
import 'package:tycg/models/round_data.dart';
import 'package:tycg/provider/operation_provider.dart';
import 'package:tycg/utils/hive_box.dart';

class OperationItemScreen extends StatefulWidget {
  const OperationItemScreen({super.key});

  @override
  State<OperationItemScreen> createState() => _OperationItemScreenState();
}

class _OperationItemScreenState extends State<OperationItemScreen> {
  final GlobalKey<_OperationItemScreenState> globalKey =
      GlobalKey<_OperationItemScreenState>();

  List<int> roundOperationIds = [];
  late OperationProvider operationProvider;
  late int roundId;

  Future<void> saveHiveBox() async {
    var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
    var data = box.get(ROUND_DATA);
    Map<String, dynamic> roundMap = jsonDecode(data);
    var roundData = RoundData.fromJson(roundMap);
    roundData.operationCategoryIds = roundOperationIds;

    await box.put(ROUND_DATA, jsonEncode(roundData.toJson()));
    await operationProvider.loadOperationInfo();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      operationProvider =
          Provider.of<OperationProvider>(context, listen: false);
      operationProvider.setLoading(true);
      //取巡檢資料
      var box = await HiveBox.openSecureBox(BOX_SECURITY_DATA);
      var data = box.get(ROUND_DATA);
      Map<String, dynamic> roundMap = jsonDecode(data);
      var roundData = RoundData.fromJson(roundMap);
      roundId = roundData.id;
      roundOperationIds = roundData.operationCategoryIds!;
      operationProvider.fetch().then((_) {
        operationProvider.setLoading(false);
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
            "作業項目",
            style: TextStyle(fontWeight: FontWeight.w600, color: sWhite),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: sWhite,
            ),
            onPressed: () {
              context.pop();
            },
          ),
          actions: [
            SizedBox(
              height: 33,
              child: ElevatedButton(
                  onPressed: () async {
                    final cxt = globalKey.currentContext;
                    operationProvider.setLoading(true);
                    bool check = await operationProvider.update(
                        roundId, roundOperationIds);
                    if (check) {
                      saveHiveBox();
                      operationProvider.setLoading(false);
                      if (cxt != null && cxt.mounted) {
                        ScaffoldMessenger.of(cxt).showSnackBar(const SnackBar(
                          content: Text("更新成功"),
                        ));
                        context.pop();
                      }
                    } else {
                      operationProvider.setLoading(false);
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
        body: Consumer<OperationProvider>(builder: (context, oper, child) {
          return LoadingOverlay(
              isLoading: oper.isLoading,
              child: SafeArea(
                child: ConstrainedBox(
                  constraints: const BoxConstraints.expand(),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [_buildOperation(oper)]),
                ),
              ));
        }));
  }

  Widget _buildOperation(OperationProvider oper) {
    List<OperationItem> riskCategory = List.from(
        oper.operationDatas?.where((item) => item.type == 0).toList() ?? []);
    List<OperationItem> normalCategory = List.from(
        oper.operationDatas?.where((item) => item.type == 2).toList() ?? []);
    return Expanded(
        child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            children: [
          const SizedBox(
            height: 10,
          ),
          const Text(
            '高風險',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(color: sGrey),
          _buildCategory(riskCategory),
          const SizedBox(
            height: 30,
          ),
          const Text(
            '一般性',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(color: sGrey),
          _buildCategory(normalCategory),
        ]));
  }

  Widget _buildCategory(List<OperationItem> items) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4,
        crossAxisSpacing: 10.0,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return SizedBox(
            child: Row(
          children: [
            Checkbox(
              value: roundOperationIds.contains(items[index].id),
              onChanged: (value) async {
                setState(() {
                  if (roundOperationIds.isNotEmpty) {
                    if (!roundOperationIds.contains(items[index].id)) {
                      roundOperationIds.add(items[index].id);
                    } else {
                      roundOperationIds.remove(items[index].id);
                    }
                  } else {
                    roundOperationIds.add(items[index].id);
                  }
                });
                operationProvider.setLoading(true);
                saveHiveBox();
                operationProvider.setLoading(false);

                debugPrint("目前作業項目 $roundOperationIds");
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                items[index].name,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ));
      },
    );
  }
}
