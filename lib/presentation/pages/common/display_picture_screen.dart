// lib/presentation/pages/common/display_picture_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('图片预览')),
      body: Center(child: Image.file(File(imagePath))),
    );
  }
}
