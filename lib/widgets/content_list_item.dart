import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:ppx_client/core/constants/AppConstants.dart';
import 'package:ppx_client/core/utils/app_logger.dart';
import 'package:ppx_client/data/models/post_item_model.dart';
import 'package:ppx_client/data/models/user_model.dart';
import 'package:ppx_client/presentation/pages/post_detail/post_detail_page.dart';
import 'package:provider/provider.dart';

import '../core/network/post_api_service.dart';
import 'content_list_videoplayer.dart'; // 确保 UserModel 被正确导入

class ContentListItem extends StatefulWidget {
  final PostItem post;

  const ContentListItem({super.key, required this.post});

  @override
  State<ContentListItem> createState() => _ContentListItemState();
}

class _ContentListItemState extends State<ContentListItem> {
  late bool _isLiked;
  late bool _isUnliked;
  late int _likesCount;
  late int _unlikesCount;
  late PostApiService _postApiService; // API 服务实例

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLiked = widget.post.isLiked;
    _likesCount = widget.post.likesCount;
    _isUnliked = widget.post.isUnliked;
    _unlikesCount = widget.post.unLikesCount;
  }

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
            _buildUserInfoRow(context, widget.post.userInfo),
            const SizedBox(height: 12.0),
            _buildContentArea(context, widget.post),
            const SizedBox(height: 12.0),
            _buildActionButtonsRow(context, widget.post),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在 didChangeDependencies 中获取 Provider 提供的服务实例
    // 因为 context 在 initState 时可能还不能安全地用于 Provider.of
    _postApiService = Provider.of<PostApiService>(context, listen: false);
  }

  Future<void> _toggleLike() async {
    // 乐观更新的准备：保存旧状态
    final oldIsLiked = _isLiked;
    final oldLikesCount = _likesCount;
    final oldIsUnliked = _isUnliked;
    final oldUnlikesCount = _unlikesCount;

    // 乐观更新UI
    setState(() {
      _isLiked = !_isLiked;
      _likesCount = _isLiked ? _likesCount + 1 : _likesCount - 1;
      if (_isLiked && _isUnliked) {
        // 如果点了赞，且之前是点踩状态，则取消点踩
        _isUnliked = false;
        _unlikesCount = oldUnlikesCount - 1 >= 0
            ? oldUnlikesCount - 1
            : 0; // 确保不为负
      }
    });

    bool success = false;
    try {
      final postItem = widget.post;
      if (oldIsLiked) {
        // 如果已经点赞，取消点赞
        success = await _postApiService.unlikePost(postItem.id);
      } else {
        // 如果未点赞，执行点赞
        success = await _postApiService.likePost(postItem.id);
      }
    } catch (e) {
      AppLogger.error('Error toggling like: $e');
      success = false;
    }

    if (!success) {
      setState(() {
        _isLiked = oldIsLiked;
        _likesCount = oldLikesCount;
        _isUnliked = oldIsUnliked;
        _unlikesCount = oldUnlikesCount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isLiked ? "取消点赞失败，请稍后重试" : '点赞失败，请稍后重试')),
      );
    } else {
      setState(() {}); // 更新界面
    }
  }

  Future<void> _toggleUnLike() async {
    // 乐观更新的准备：保存旧状态
    final oldIsLiked = _isLiked;
    final oldLikesCount = _likesCount;
    final oldIsUnliked = _isUnliked;
    final oldUnlikesCount = _unlikesCount;

    // 乐观更新UI
    setState(() {
      _isUnliked = !_isUnliked;
      _unlikesCount = _isUnliked ? _unlikesCount + 1 : _unlikesCount - 1;
      if (_isLiked && _isUnliked) {
        // 如果点了赞，且之前是点踩状态，则取消点踩
        _isLiked = false;
        _likesCount = oldLikesCount - 1 >= 0
            ? oldLikesCount - 1
            : 0; // 确保不为负
      }
    });

    bool success = false;
    try {
      final postItem = widget.post;
      if (oldIsUnliked) {
        // 如果已经点赞，取消点赞
        success = await _postApiService.undislikePost(postItem.id);
      } else {
        // 如果未点赞，执行点赞
        success = await _postApiService.dislikePost(postItem.id);
      }
    } catch (e) {
      AppLogger.error('Error toggling like: $e');
      success = false;
    }

    if (!success) {
      setState(() {
        _isLiked = oldIsLiked;
        _likesCount = oldLikesCount;
        _isUnliked = oldIsUnliked;
        _unlikesCount = oldUnlikesCount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isLiked ? "取消点赞失败，请稍后重试" : '点赞失败，请稍后重试')),
      );
    } else {
      setState(() {}); // 更新界面
    }
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
        if (widget.post.postType == PostType.advertisement)
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
          icon: _isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
          label: _likesCount.toString(),
          color: _isLiked ? Theme.of(context).primaryColor : Colors.grey,
          onPressed: () {
            // TODO: 实现点赞/取消点赞逻辑
            _toggleLike();
            AppLogger.info('Like button tapped for post ${post.id}');
          },
        ),
        _buildActionButton(
          context,
          icon: _isUnliked
              ? Icons.thumb_down_alt
              : Icons.thumb_down_alt_outlined,
          label: _unlikesCount.toString(),
          color: _isUnliked ? Theme.of(context).primaryColor : Colors.grey,
          onPressed: () {
            // TODO: 实现踩/取消踩逻辑
            _toggleUnLike();
            AppLogger.info('Dislike button tapped for post ${post.id}');
          },
        ),
        _buildActionButton(
          context,
          icon: Icons.comment_outlined,
          label: post.commentsCount.toString(),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
            );
          },
        ),
        _buildActionButton(
          context,
          icon: Icons.share_outlined,
          label: '分享', // 分享通常不显示数量
          onPressed: () {
            // TODO: Implement share functionality
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
