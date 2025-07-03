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
  Future<void> loadPosts({bool isRefresh = false, int? userId, int? categoryId}) async {
    if (isRefresh) {
      _isLoadingMore = true;
      _errorMessage = null;
    } else {
      _isLoadingInitial = true;
    }
    notifyListeners();

    bool cacheLoaded = false;
    if (!isRefresh && userId == null && categoryId == null) { // Only load from cache for general feed
      try {
        final cachedPosts = await _repository.getCachedPosts();
        if (cachedPosts.isNotEmpty) {
          _posts = cachedPosts;
          cacheLoaded = true;
          _isLoadingInitial = false;
          notifyListeners();
        }
      } catch (e) {
        AppLogger.error("ViewModel: Error loading cached posts: $e");
      }
    }

    if (!cacheLoaded && !isRefresh) {
      _isLoadingInitial = false;
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final remotePosts = await _repository.fetchAndCacheRemotePosts(
        clearCacheFirst: isRefresh,
        userId: userId,
        categoryId: categoryId,
      );
      _posts = remotePosts;
      _errorMessage = null;
    } catch (e) {
      AppLogger.error("ViewModel: Error fetching remote posts: $e");
      _errorMessage = "无法加载最新内容: ${e.toString()}";
    } finally {
      _isLoadingInitial = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  int _currentPage = 1;

  Future<void> loadMorePosts({int? userId, int? categoryId}) async {
    if (_isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final newPosts = await _repository.fetchAndCacheRemotePosts(userId: userId, categoryId: categoryId, page: _currentPage);
      _posts.addAll(newPosts);
      if (newPosts.isNotEmpty) {
        _currentPage++;
      }
      _errorMessage = null;
    } catch (e) {
      AppLogger.error("ViewModel: Error fetching more remote posts: $e");
      _errorMessage = "无法加载更多内容: ${e.toString()}";
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // TODO: 实现点赞/踩等交互方法，调用Repository，并更新_posts中对应item的状态
  // Future<void> toggleLike(String postId) async { ... }
}
