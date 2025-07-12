import 'package:flutter/material.dart';
import 'package:ppx_client/data/models/comment_model.dart';

class CommentWidget extends StatelessWidget {
  final Comment comment;
  final Function(int) onReply;

  const CommentWidget({super.key, required this.comment, required this.onReply});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(comment.userInfo?.avatar ?? 'https://via.placeholder.com/150'),
              ),
              const SizedBox(width: 8),
              Text(comment.userInfo?.name ?? '匿名用户', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment.content),
          TextButton(
            onPressed: () => onReply(comment.id),
            child: const Text('回复'),
          ),
          if (comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 40.0, top: 8.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comment.replies.length,
                itemBuilder: (context, index) {
                  return CommentWidget(comment: comment.replies[index], onReply: onReply);
                },
              ),
            ),
        ],
      ),
    );
  }
}