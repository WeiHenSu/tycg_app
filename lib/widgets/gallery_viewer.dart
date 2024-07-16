import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:tycg/configs/app_colors.dart';

class GalleryViewer extends StatefulWidget {
  ///圖片瀏覽
  final List galleryItems;
  final int defaultImage;
  final Axis direction;
  final BoxDecoration? decoration;

  const GalleryViewer({
    Key? key,
    required this.galleryItems,
    this.defaultImage = 0,
    this.direction = Axis.horizontal,
    required this.decoration,
  }) : super(key: key);

  @override
  State<GalleryViewer> createState() => _GallerViewerState();
}

class _GallerViewerState extends State<GalleryViewer> {
  late int tempSelect;
  late int currentIndex;
  @override
  void initState() {
    super.initState();
    currentIndex = widget.defaultImage;
    tempSelect = widget.defaultImage + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: sBlack.withOpacity(0.1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: sWhite,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                '$tempSelect/${widget.galleryItems.length}',
                style: const TextStyle(
                  color: sWhite,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: widget.galleryItems[index].photo,
                );
              },
              scrollDirection: widget.direction,
              itemCount: widget.galleryItems.length,
              loadingBuilder: (context, progress) => Center(
                    child: SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        value: progress == null
                            ? null
                            : progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!,
                      ),
                    ),
                  ),
              backgroundDecoration: widget.decoration,
              pageController: PageController(initialPage: widget.defaultImage),
              onPageChanged: (index) => setState(() {
                    tempSelect = index + 1;
                    currentIndex = index;
                  })),
          if (widget.galleryItems[currentIndex].title != null)
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                widget.galleryItems[currentIndex]?.title ?? '',
                style: const TextStyle(
                  color: sWhite,
                  fontSize: 17.0,
                  decoration: null,
                ),
              ),
            )
        ],
      ),
    );
  }
}
