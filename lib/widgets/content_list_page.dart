import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ppx_client/data/models/category_model.dart';

import '../presentation/viewmodels/post_list_viewmodel.dart';
import 'content_list_item.dart';
import 'custom_refresh_indicator.dart';

class ContentListPage extends StatefulWidget {
  final int? userId;
  final Category? category;

  const ContentListPage({super.key, this.userId, this.category});

  @override
  State<ContentListPage> createState() => _ContentListPageState();
}

class _ContentListPageState extends State<ContentListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialLoad();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.9 &&
          !Provider.of<PostListViewModel>(context, listen: false).isLoadingMore) {
        _loadMore();
      }
    });
  }

  void _initialLoad() {
    Provider.of<PostListViewModel>(context, listen: false).loadPosts(userId: widget.userId, categoryId: widget.category?.id);
  }

  void _loadMore() {
    Provider.of<PostListViewModel>(context, listen: false).loadMorePosts(userId: widget.userId, categoryId: widget.category?.id);
  }

  Future<void> _handleRefresh() async {
    await Provider.of<PostListViewModel>(context, listen: false).loadPosts(isRefresh: true, userId: widget.userId, categoryId: widget.category?.id);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostListViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoadingInitial && viewModel.posts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null && viewModel.posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('错误: ${viewModel.errorMessage}'),
                ElevatedButton(onPressed: _handleRefresh, child: const Text('重试')),
              ],
            ),
          );
        }
        if (viewModel.posts.isEmpty &&
            !viewModel.isLoadingInitial &&
            !viewModel.isLoadingMore) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('没有帖子哦，刷新试试？'),
                ElevatedButton(onPressed: _handleRefresh, child: const Text('刷新')),
              ],
            ),
          );
        }

        return CustomRefreshIndicator(
          lottieAssetPath: 'assets/animations/pull_to_refresh.json',
          onRefresh: _handleRefresh,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            controller: _scrollController,
            itemCount: viewModel.posts.length + (viewModel.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == viewModel.posts.length && viewModel.isLoadingMore) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (index >= viewModel.posts.length) return null;

              final post = viewModel.posts[index];
              return ContentListItem(post: post);
            },
          ),
        );
      },
    );
  }
}