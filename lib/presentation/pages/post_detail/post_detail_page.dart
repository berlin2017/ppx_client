import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ppx_client/data/models/post_item_model.dart';
import 'package:ppx_client/presentation/viewmodels/comment_viewmodel.dart';
import 'package:ppx_client/presentation/pages/post_detail/comment_widget.dart';
import 'package:ppx_client/core/network/api_service.dart';
import 'package:ppx_client/core/constants/AppConstants.dart';
import 'package:ppx_client/widgets/content_list_videoplayer.dart';
import 'package:share_plus/share_plus.dart';

class PostDetailPage extends StatefulWidget {
  final PostItem post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  bool _isLiked = false;
  bool _isDisliked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommentViewModel>(context, listen: false).fetchComments(widget.post.id);
    });
  }

  void _showCommentInputDialog({int? parentId}) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(parentId == null ? '添加评论' : '回复评论'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '输入你的评论...'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Provider.of<CommentViewModel>(context, listen: false).addComment(
                    widget.post.id,
                    controller.text,
                    parentId: parentId,
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('发送'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CommentViewModel(apiService: Provider.of<ApiService>(context, listen: false)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.post.userInfo.name),
        ),
        body: Builder(
          builder: (context) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildContentArea(context, widget.post),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text('评论', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: Consumer<CommentViewModel>(
                    builder: (context, viewModel, child) {
                      if (viewModel.isLoading && viewModel.comments.isEmpty) {
                        return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                      }
                      if (viewModel.errorMessage != null) {
                        return SliverToBoxAdapter(child: Center(child: Text(viewModel.errorMessage!)));
                      }
                      if (viewModel.comments.isEmpty) {
                        return const SliverToBoxAdapter(child: Center(child: Text('暂无评论，快来抢沙发吧！')));
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return CommentWidget(
                              comment: viewModel.comments[index],
                              onReply: (parentId) => _showCommentInputDialog(parentId: parentId),
                            );
                          },
                          childCount: viewModel.comments.length,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        ),
        bottomNavigationBar: _buildBottomAppBar(),
      ),
    );
  }

  Widget _buildContentArea(BuildContext context, PostItem post) {
    List<Widget> contentWidgets = [];

    if (post.content != null && post.content!.isNotEmpty) {
      contentWidgets.add(
        Text(
          post.content!,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
        ),
      );
      contentWidgets.add(const SizedBox(height: 12.0));
    }

    switch (post.postType) {
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
      default:
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contentWidgets,
    );
  }

  Widget _buildImagesArea(BuildContext context, List<String> images) {
    return AspectRatio(
      aspectRatio: 1,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                AppConstants.baseUrl + images[index],
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoArea(BuildContext context, String videoUrl) {
    return VideoPlayerItem(videoUrl: videoUrl);
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _showCommentInputDialog(),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).splashColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: const Text('添加评论...', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ),
            IconButton(
              icon: Icon(_isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined, color: _isLiked ? Colors.blue : null),
              onPressed: () => setState(() {
                _isLiked = !_isLiked;
                if (_isLiked) _isDisliked = false;
              }),
            ),
            IconButton(
              icon: Icon(_isDisliked ? Icons.thumb_down : Icons.thumb_down_alt_outlined, color: _isDisliked ? Colors.red : null),
              onPressed: () => setState(() {
                _isDisliked = !_isDisliked;
                if (_isDisliked) _isLiked = false;
              }),
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // TODO: Implement share functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}