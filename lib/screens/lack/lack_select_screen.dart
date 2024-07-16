import 'package:flutter/material.dart';
import 'package:tycg/configs/app_colors.dart';
import 'package:go_router/go_router.dart';

class LackSelectScreen extends StatefulWidget {
  const LackSelectScreen({required this.extra, super.key});

  final List<dynamic> extra;

  @override
  State<LackSelectScreen> createState() => _LackSelectScreenState();
}

class _LackSelectScreenState extends State<LackSelectScreen> {
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
                                        onPressed: () {
                                          context.pop(
                                              {'value': itemList[index]['id']});
                                        },
                                        child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              itemList[index]
                                                      .containsKey('code')
                                                  ? itemList[index]['code'] +
                                                      " - " +
                                                      itemList[index]['name']
                                                  : itemList[index]['name'],
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
