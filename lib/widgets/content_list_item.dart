import 'package:flutter/material.dart';
import 'package:ppx_client/core/constants/AppConstants.dart';
import 'package:ppx_client/core/utils/app_logger.dart';
import 'package:ppx_client/data/models/post_item_model.dart';
import 'package:ppx_client/data/models/user_model.dart';

import 'content_list_videoplayer.dart'; // 确保 UserModel 被正确导入

class ContentListItem extends StatelessWidget {
  final PostItem post;

  const ContentListItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfoRow(context, post.userInfo),
            const SizedBox(height: 12.0),
            _buildContentArea(context, post),
            const SizedBox(height: 12.0),
            _buildActionButtonsRow(context, post),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(BuildContext context, UserModel userInfo) {
    return Row(
      children: [
        CircleAvatar(
          // 尝试加载网络头像，如果avatar为空或加载失败，显示默认图标
          backgroundImage:
              (userInfo.avatar != null && userInfo.avatar!.isNotEmpty)
              ? NetworkImage(AppConstants.baseUrl + userInfo.avatar!)
              : null,
          radius: 20,
          child: (userInfo.avatar == null || userInfo.avatar!.isEmpty)
              ? const Icon(Icons.person, size: 24)
              : null,
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            userInfo.name, // 使用 userInfo 中的 name
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        // 可以添加更多按钮，比如关注按钮或更多操作菜单
        if (post.postType == PostType.advertisement)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400, width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '广告',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }

  Widget _buildContentArea(BuildContext context, PostItem post) {
    List<Widget> contentWidgets = [];

    // 1. 添加文字内容 (如果存在)
    if (post.content != null && post.content!.isNotEmpty) {
      contentWidgets.add(
        Text(
          post.content!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15),
        ),
      );
      contentWidgets.add(const SizedBox(height: 8.0)); // 文字和媒体之间的间距
    }

    // 2. 根据帖子类型添加媒体内容
    switch (post.postType) {
      case PostType.text:
        // 纯文本帖，如果上面已经加了文字，这里不需要额外操作
        // 如果文字内容为空但类型是text，可以显示一个提示或留空
        if (contentWidgets.isEmpty) {
          contentWidgets.add(const SizedBox.shrink()); // 避免空内容区域
        }
        break;
      case PostType.image:
        if (post.images != null && post.images!.isNotEmpty) {
          contentWidgets.add(_buildImagesArea(context, post.images!));
        }
        break;
      case PostType.video:
        if (post.videoUrl != null && post.videoUrl!.isNotEmpty) {
          contentWidgets.add(_buildVideoArea(context, post.videoUrl!));
        }
        break;
      case PostType.advertisement:
        // 广告类型可能优先展示图片，然后是文字（如果文字没在上面显示的话）
        if (post.images != null && post.images!.isNotEmpty) {
          contentWidgets.add(_buildImagesArea(context, post.images!));
        } else if (contentWidgets.isEmpty &&
            (post.content == null || post.content!.isEmpty)) {
          // 如果广告既没有图片也没有文字，可以显示一个默认的广告占位
          contentWidgets.add(
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: const Center(
                child: Text("广告内容区域", style: TextStyle(color: Colors.grey)),
              ),
            ),
          );
        }
        break;
    }
    // 如果没有任何内容widget被添加（例如一个空的text post），确保返回一个空的SizedBox
    if (contentWidgets.isEmpty ||
        (contentWidgets.length == 1 &&
            contentWidgets.first is SizedBox &&
            (contentWidgets.first as SizedBox).height == 8.0)) {
      return const SizedBox.shrink();
    }
    // 移除可能因为只有文字内容而多加的末尾SizedBox
    if (contentWidgets.isNotEmpty &&
        contentWidgets.last is SizedBox &&
        (contentWidgets.last as SizedBox).height == 8.0) {
      if (!((post.postType == PostType.image &&
              post.images != null &&
              post.images!.isNotEmpty) ||
          (post.postType == PostType.video &&
              post.videoUrl != null &&
              post.videoUrl!.isNotEmpty) ||
          (post.postType == PostType.advertisement &&
              post.images != null &&
              post.images!.isNotEmpty))) {
        contentWidgets.removeLast();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contentWidgets,
    );
  }

  Widget _buildImagesArea(BuildContext context, List<String> images) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    if (images.length == 1) {
      // 单张图片
      return AspectRatio(
        aspectRatio: 16 / 9, // 或者根据图片实际比例调整
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            AppConstants.baseUrl + images.first,
            fit: BoxFit.cover,
            // 建议使用 cached_network_image 处理加载、错误和缓存
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        ),
      );
    } else {
      // 多张图片 - 九宫格
      return _buildGridViewForImages(context, images);
    }
  }

  Widget _buildGridViewForImages(BuildContext context, List<String> images) {
    // 限制最多显示9张图片
    final displayImages = images.take(9).toList();
    int crossAxisCount = displayImages.length <= 4 ? 2 : 3;
    if (displayImages.length == 1)
      crossAxisCount = 1; // 应该不会到这里，因为单图在 _buildImagesArea 处理

    return GridView.builder(
      shrinkWrap: true,
      // 重要：在Column中需要
      physics: const NeverScrollableScrollPhysics(),
      // 重要：禁用GridView的滚动
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
        // 根据图片数量调整宽高比，尽量保持方形
        childAspectRatio:
            (displayImages.length == 2 || displayImages.length == 4)
            ? 1.2
            : 1.0,
      ),
      itemCount: displayImages.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: Image.network(
            AppConstants.baseUrl + displayImages[index],
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoArea(BuildContext context, String videoUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: VideoPlayerItem(videoUrl: videoUrl),
    );
  }

  Widget _buildActionButtonsRow(BuildContext context, PostItem post) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          context,
          icon: post.isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
          label: post.likesCount.toString(),
          color: post.isLiked ? Theme.of(context).primaryColor : Colors.grey,
          onPressed: () {
            // TODO: 实现点赞/取消点赞逻辑
            AppLogger.info('Like button tapped for post ${post.id}');
          },
        ),
        _buildActionButton(
          context,
          icon: post.isUnliked
              ? Icons.thumb_down_alt
              : Icons.thumb_down_alt_outlined,
          label: post.unLikesCount.toString(),
          color: post.isUnliked ? Theme.of(context).primaryColor : Colors.grey,
          onPressed: () {
            // TODO: 实现踩/取消踩逻辑
            AppLogger.info('Dislike button tapped for post ${post.id}');
          },
        ),
        _buildActionButton(
          context,
          icon: Icons.comment_outlined,
          label: post.commentsCount.toString(),
          onPressed: () {
            // TODO: 实现评论功能/导航到评论页
            AppLogger.info('Comment button tapped for post ${post.id}');
          },
        ),
        _buildActionButton(
          context,
          icon: Icons.share_outlined,
          label: '分享', // 分享通常不显示数量
          onPressed: () {
            // TODO: 实现分享逻辑
            AppLogger.info('Share button tapped for post ${post.id}');
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      icon: Icon(icon, color: color ?? Colors.grey, size: 20),
      label: Text(
        label,
        style: TextStyle(color: color ?? Colors.grey, fontSize: 13),
      ),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero, // 移除最小尺寸限制
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 减小点击区域
      ),
    );
  }
}
