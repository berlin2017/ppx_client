import 'package:flutter/material.dart';
import 'package:ppx_client/data/models/post_item_model.dart';
import 'package:ppx_client/data/repositories/post_repository.dart';

class MyPostsViewModel extends ChangeNotifier {
  final PostRepository _postRepository;

  MyPostsViewModel(this._postRepository);

  List<PostItem> _posts = [];
  List<PostItem> get posts => _posts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _page = 0;

  Future<void> fetchMyPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final newPosts = await _postRepository.fetchMyPosts(page: _page);
      _posts.addAll(newPosts);
      _page++;
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }
}
