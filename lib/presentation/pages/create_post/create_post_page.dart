// lib/presentation/pages/create_post/create_post_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/network/post_api_service.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<XFile> _selectedImages = [];
  XFile? _selectedVideo;

  bool _isLoading = false; // 用于表示是否正在上传/处理

  // 图片选择逻辑
  Future<void> _pickImages() async {
    if (_selectedImages.length >= 9) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('最多只能选择9张图片')));
      return;
    }
    if (_selectedVideo != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已选择视频，如需选择图片请先移除视频')));
      return;
    }

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        limit: 9 - _selectedImages.length,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          for (var file in pickedFiles) {
            if (_selectedImages.length < 9) {
              _selectedImages.add(file);
            } else {
              break;
            }
          }
        });
      }
    } catch (e) {
      print("选择图片时发生错误: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('选择图片失败')));
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // 视频选择逻辑
  Future<void> _pickVideo() async {
    if (_selectedImages.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已选择图片，如需选择视频请先移除图片')));
      return;
    }
    if (_selectedVideo != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('只能选择一个视频')));
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedVideo = pickedFile;
        });
      }
    } catch (e) {
      print("选择视频时发生错误: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('选择视频失败')));
      }
    }
  }

  void _removeVideo() {
    setState(() {
      _selectedVideo = null;
    });
  }

  // 发表逻辑
  Future<void> _publishPost() async {
    if (_textController.text.isEmpty &&
        _selectedImages.isEmpty &&
        _selectedVideo == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入内容或选择媒体文件')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await Provider.of<PostApiService>(context, listen: false)
        .publishPost(
          textContent: _textController.text,
          imageFiles: _selectedImages,
          videoFile: _selectedVideo,
        );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('内容已发表!')));
      // 发表成功后可以清空或导航离开
      _textController.clear();
      setState(() {
        _selectedImages.clear();
        _selectedVideo = null;
      });
      // Example: Pop after a short delay if you want to show the SnackBar first
      // Future.delayed(const Duration(seconds: 1), () {
      //   if (Navigator.canPop(context)) Navigator.pop(context);
      // });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('发表失败，请稍后重试')));
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发表动态'),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _publishPost,
                  tooltip: '发表',
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 文字输入区域
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: '分享新鲜事...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              maxLength: 500,
            ),
            const SizedBox(height: 16),

            // 媒体选择按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed:
                      (_selectedVideo != null || _selectedImages.length >= 9)
                      ? null
                      : _pickImages,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('图片'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed:
                      (_selectedImages.isNotEmpty || _selectedVideo != null)
                      ? null
                      : _pickVideo,
                  icon: const Icon(Icons.videocam),
                  label: const Text('视频'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 已选图片预览
            _buildImageThumbnails(),

            // 已选视频预览
            _buildVideoPreview(),

            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnails() {
    if (_selectedImages.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("已选图片:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _selectedImages.asMap().entries.map((entry) {
            int idx = entry.key;
            XFile imageFile = entry.value;
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    File(imageFile.path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () => _removeImage(idx),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildVideoPreview() {
    if (_selectedVideo == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("已选视频:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.black,
              child: const Icon(
                Icons.play_circle_fill,
                color: Colors.white54,
                size: 60,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: _removeVideo,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                _selectedVideo!.name,
                style: const TextStyle(
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
