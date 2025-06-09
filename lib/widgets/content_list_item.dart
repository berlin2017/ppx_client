import 'package:flutter/material.dart';

class ContentListItem extends StatelessWidget {
  final String itemName; // Example: Pass item name or data

  const ContentListItem({super.key, required this.itemName});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Row
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 8.0),
                Text(
                  'User Name', // Placeholder
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12.0),

            // Content
            Text(
              'Item: $itemName', // Displaying passed item name
              // 'Article content goes here. This could be a longer text, an image, or a video preview.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12.0),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up_alt_outlined),
                  onPressed: () {
                    // Handle like action
                  },
                ),
                Text('Like'), // Placeholder for like count
                IconButton(
                  icon: const Icon(Icons.thumb_down_alt_outlined),
                  onPressed: () {
                    // Handle dislike action
                  },
                ),
                Text('Dislike'), // Placeholder for dislike count
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    // Handle share action
                  },
                ),
                Text('Share'), // Placeholder for share count
              ],
            ),
          ],
        ),
      ),
    );
  }
}
