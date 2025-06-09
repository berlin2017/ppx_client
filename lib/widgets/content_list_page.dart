import 'package:flutter/material.dart';
import 'content_list_item.dart';
import 'custom_refresh_indicator.dart'; // Ensure this path is correct

class ContentListPage extends StatefulWidget {
  final String category; // Example: To know which category this page is for

  const ContentListPage({super.key, this.category = 'Default'});

  @override
  State<ContentListPage> createState() => _ContentListPageState();
}

class _ContentListPageState extends State<ContentListPage> {
  List<String> _items = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _itemsPerPage = 20;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9 &&
          !_isLoadingMore &&
          _hasMoreData) {
        _loadMoreData();
      }
    });
  }

  Future<void> _loadInitialData() async {
    // Simulate network call
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _items = List.generate(_itemsPerPage, (index) => '${widget.category} Item ${index + 1}');
      _currentPage = 1;
      _hasMoreData = true;
    });
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate network call
    await Future.delayed(const Duration(seconds: 2));
    List<String> newItems = List.generate(
        _itemsPerPage,
        (index) => '${widget.category} Item ${(_currentPage * _itemsPerPage) + index + 1}');

    setState(() {
      _items.addAll(newItems);
      _currentPage++;
      _isLoadingMore = false;
      // Example: Stop loading if we've loaded, say, 100 items for demo
      if (_items.length >= 100) {
        _hasMoreData = false;
      }
    });
  }

  Future<void> _handleRefresh() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _items = List.generate(
          _itemsPerPage, (index) => 'Refreshed ${widget.category} Item ${index + 1}');
      _currentPage = 1;
      _hasMoreData = true;
      _isLoadingMore = false; // Reset loading more state
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      lottieAssetPath: 'assets/animations/pull_to_refresh.json', // Ensure this Lottie file exists
      onRefresh: _handleRefresh,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()), // <--- 添加这行
        controller: _scrollController,
        itemCount: _items.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _items.length && _isLoadingMore) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (index >= _items.length) {
            return null; // Should not happen if itemCount is correct
          }
          return ContentListItem(itemName: _items[index]);
        },
      ),
    );
  }
}
