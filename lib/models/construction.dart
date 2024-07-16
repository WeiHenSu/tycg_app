import 'package:flutter/material.dart';

class Construction {
  const Construction({
    required this.name,
    required this.type,
    required this.image,
    required this.color,
  });

  final Color color;
  final String image;
  final String name;
  final String type;
}
