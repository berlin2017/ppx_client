
import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
      ),
      body: const Center(
        child: Text(
          'Messages Page Content',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
