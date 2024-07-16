import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tycg/configs/app_colors.dart';
import 'package:go_router/go_router.dart';

class PhotoViewScreen extends StatelessWidget {
  const PhotoViewScreen({
    super.key,
    required this.imageProvider,
  });

  final ImageProvider imageProvider;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              right: 0,
              child: PhotoView(
                imageProvider: imageProvider,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2,
              ),
            ),
            Positioned(
              right: 5,
              top: MediaQuery.of(context).padding.top,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 30,
                  color: sWhite,
                ),
                onPressed: () {
                  context.pop();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
