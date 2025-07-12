
import 'package:flutter/material.dart';

class CommentsTab extends StatelessWidget {
  const CommentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('评论 $index'),
          subtitle: const Text('这是评论的内容...'),
        );
      },
    );
  }
}
