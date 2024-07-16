import 'dart:io';

class ImageUpload {
  String? id;
  String filename;
  File imageFile;
  String imageUrl;

  ImageUpload({
    this.id,
    required this.filename,
    required this.imageFile,
    required this.imageUrl,
  });
}
