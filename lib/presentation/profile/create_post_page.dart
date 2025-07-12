
import 'package:flutter/material.dart';

class CreatePostPage extends StatelessWidget {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发布内容'),
      ),
      body: const Center(
        child: Text('这里是发布内容的页面'),
      ),
    );
  }
}
