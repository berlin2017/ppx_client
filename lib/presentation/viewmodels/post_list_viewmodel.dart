// lib/viewmodels/post_list_viewmodel.dart
import 'package:flutter/foundation.dart'; // 或者 'package:flutter/material.dart';
import 'package:ppx_client/core/utils/app_logger.dart';
import 'package:ppx_client/data/models/post_item_model.dart';

import '../../data/repositories/post_repository.dart';

class PostListViewModel extends ChangeNotifier {
  final PostRepository _repository;

  PostListViewModel({required PostRepository repository})
    : _repository = repository;

  List<PostItem> _posts = [];

  List<PostItem> get posts => _posts;

  bool _isLoadingInitial = true; // 初始加载（数据库）
  bool get isLoadingInitial => _isLoadingInitial;

  bool _isLoadingMore = false; // 加载更多或刷新
  bool get isLoadingMore => _isLoadingMore;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  // 统一的加载方法
  Future<void> loadPosts({bool isRefresh = false}) async {
    if (isRefresh) {
      _isLoadingMore = true;
      _errorMessage = null; // 清除旧错误
      // 通常在刷新时，我们希望清除旧数据并显示加载指示器，
      // 但这里我们先加载缓存，再请求网络，所以 _posts 不会立即清空
    } else {
      _isLoadingInitial = true;
    }
    notifyListeners();

    bool cacheLoaded = false;
    // 1. 尝试从缓存加载 (仅在非刷新或首次加载时，或希望刷新时也先显示旧数据)
    if (!isRefresh) {
      // 或者根据你的刷新策略调整
      try {
        final cachedPosts = await _repository.getCachedPosts();
        if (cachedPosts.isNotEmpty) {
          _posts = cachedPosts;
          cacheLoaded = true;
          // 如果是从缓存加载的，初始加载完成
          _isLoadingInitial = false;
          notifyListeners(); // 立即显示缓存数据
        }
      } catch (e) {
        AppLogger.error("ViewModel: Error loading cached posts: $e");
        // 缓存加载失败，继续尝试网络加载
      }
    }

    // 2. 总是尝试从网络获取最新数据
    // 如果是刷新，isLoadingMore 应该为 true
    // 如果是首次加载且缓存为空，isLoadingInitial 应该为 true (或转为 isLoadingMore)
    if (!cacheLoaded && !isRefresh) {
      // 如果缓存为空且不是刷新，也认为是在加载更多/网络
      _isLoadingInitial = false; // 初始（缓存）阶段结束
      _isLoadingMore = true; // 网络加载阶段开始
      notifyListeners();
    }

    try {
      final remotePosts = await _repository.fetchAndCacheRemotePosts(
        clearCacheFirst: isRefresh,
      );
      _posts = remotePosts; // 使用最新的网络数据更新列表
      _errorMessage = null; // 成功获取，清除错误信息
    } catch (e) {
      AppLogger.error("ViewModel: Error fetching remote posts: $e");
      _errorMessage = "无法加载最新内容: ${e.toString()}";
      // 如果网络失败，_posts 列表将保持为之前从缓存加载的数据（如果有）
      // 如果缓存也没有数据，那么 _posts 仍然是空的
    } finally {
      _isLoadingInitial = false; // 确保最终初始加载状态为false
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // TODO: 实现分页加载逻辑 (loadMorePosts)
  // Future<void> loadMorePosts() async { ... }

  // TODO: 实现点赞/踩等交互方法，调用Repository，并更新_posts中对应item的状态
  // Future<void> toggleLike(String postId) async { ... }
}
