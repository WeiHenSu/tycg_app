import 'package:flutter/material.dart';
import 'package:tycg/configs/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:tycg/models/lackcontent_data.dart';

class ThirdSelectScreen extends StatefulWidget {
  const ThirdSelectScreen({required this.extra, super.key});

  final List<dynamic> extra;

  @override
  State<ThirdSelectScreen> createState() => _ThirdSelectScreenState();
}

class _ThirdSelectScreenState extends State<ThirdSelectScreen> {
  List<String> qualityTypeName = ['W1', 'W2', 'W3'];
  Future<dynamic> _showCustomModalBottomSheet(
      context, List<dynamic> options) async {
    return showModalBottomSheet<dynamic>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          height: MediaQuery.of(context).size.height / 1.5,
          child: Column(children: [
            SizedBox(
              height: 50,
              child: Stack(
                textDirection: TextDirection.rtl,
                children: [
                  const Center(
                    child: Text(
                      '缺失內容',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                ],
              ),
            ),
            const Divider(height: 1.0),
            Expanded(
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                      title: Text(options[index]['code'] +
                          ' - ' +
                          options[index]['name']),
                      onTap: () {
                        context.pop(options[index]);
                      });
                },
                itemCount: options.length,
              ),
            ),
          ]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemList = widget.extra;

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: sBlack,
            ),
            onPressed: () {
              context.pop();
            },
          ),
        ),
        backgroundColor: sWhite,
        body: SafeArea(
            child: ConstrainedBox(
                constraints: const BoxConstraints.expand(),
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: itemList.length,
                      itemBuilder: (context, index) {
                        return Column(children: [
                          Row(
                            children: [
                              Expanded(
                                  child: SizedBox(
                                child: Row(children: [
                                  Container(
                                    padding: const EdgeInsets.all(4.0),
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle, color: sPurple),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                        style: ButtonStyle(
                                            shape: MaterialStatePropertyAll(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0.0)))),
                                        onPressed: () async {
                                          if (itemList[index]['childList']
                                              .isNotEmpty) {
                                            await _showCustomModalBottomSheet(
                                                    context,
                                                    itemList[index]
                                                        ['childList'])
                                                .then((value) {
                                              if (value != null) {
                                                context.pop({'value': value});
                                              }
                                            });
                                          } else {
                                            context.pop(
                                                {'value': itemList[index]});
                                          }
                                        },
                                        child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              itemList[index]['code'] +
                                                  ' - ' +
                                                  itemList[index]['name'],
                                              style:
                                                  const TextStyle(fontSize: 18),
                                              textAlign: TextAlign.start,
                                            ))),
                                  )
                                ]),
                              ))
                            ],
                          ),
                          const Divider(
                            color: sLightGrey,
                            thickness: 2,
                          ),
                        ]);
                      },
                    )))));
  }
}
