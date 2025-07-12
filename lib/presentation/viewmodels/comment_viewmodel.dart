import 'package:flutter/material.dart';
import 'package:ppx_client/data/models/comment_model.dart';
import 'package:ppx_client/core/network/api_service.dart';

class CommentViewModel extends ChangeNotifier {
  final ApiService apiService;

  CommentViewModel({required this.apiService});

  List<Comment> _comments = [];
  List<Comment> get comments => _comments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchComments(int postId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _comments = await apiService.getComments(postId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addComment(int postId, String content, {int? parentId}) async {
    try {
      await apiService.addComment(postId, content, parentId: parentId);
      await fetchComments(postId); // Refresh comments after adding a new one
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}