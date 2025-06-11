// lib/presentation/pages/create_post/create_post_page.dart
import 'dart:io';

import 'package:dotted_border/dotted_border.dart'; // Ensure this import is present
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart'; // Ensure this import is present

// Assuming PostApiService is in this path, adjust if necessary
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

  bool _isLoading = false;

  Future<void> _pickImages() async {
    if (_selectedVideo != null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已选择视频，如需选择图片请先移除视频')));
      }
      return;
    }
    if (_selectedImages.length >= 9) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('最多只能选择9张图片')));
      }
      return;
    }

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        // Limit argument can be inconsistent across image_picker versions/platforms
        // We will manually limit the addition below for robustness
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          for (var file in pickedFiles) {
            if (_selectedImages.length < 9) {
              _selectedImages.add(file);
            } else {
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('已达到9张图片上限')));
              }
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

  Future<void> _pickVideo() async {
    if (_selectedImages.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已选择图片，如需选择视频请先移除图片')));
      }
      return;
    }
    if (_selectedVideo != null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('只能选择一个视频')));
      }
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

  Future<void> _publishPost() async {
    if (_textController.text.isEmpty &&
        _selectedImages.isEmpty &&
        _selectedVideo == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('请输入内容或选择媒体文件')));
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Use PostApiService from Provider
    final postApiService = Provider.of<PostApiService>(context, listen: false);
    final result = await postApiService.publishPost(
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
      _textController.clear();
      setState(() {
        _selectedImages.clear();
        _selectedVideo = null;
      });
      // Optional: Pop after a delay
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

  Widget _buildAddImageButton({bool isFullWidth = false}) {
    return InkWell(
      onTap: _pickImages,
      borderRadius: BorderRadius.circular(8.0),
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(8.0),
        color: Colors.grey.shade400,
        strokeWidth: 1.5,
        dashPattern: const [6, 3],
        child: Container(
          width: isFullWidth ? double.infinity : 100,
          height: isFullWidth ? 120 : 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade100.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo_outlined,
                color: Colors.grey.shade600,
                size: isFullWidth ? 36 : 30,
              ),
              if (isFullWidth) const SizedBox(height: 8),
              if (isFullWidth)
                Text("添加图片", style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发表动态'),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.send_outlined),
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
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: '分享新鲜事...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
              maxLines: 5,
              maxLength: 500,
            ),
            const SizedBox(height: 20),

            Text(
              "选择媒体 (图片或视频选其一)",
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        (_selectedVideo != null || _selectedImages.length >= 9)
                        ? null
                        : _pickImages,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('图片'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                      backgroundColor: Colors.blueAccent.withOpacity(0.1),
                      foregroundColor: Colors.blueAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        (_selectedImages.isNotEmpty || _selectedVideo != null)
                        ? null
                        : _pickVideo,
                    icon: const Icon(Icons.videocam_outlined),
                    label: const Text('视频'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                      backgroundColor: Colors.green.withOpacity(0.1),
                      foregroundColor: Colors.green,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (_selectedImages.isEmpty && _selectedVideo == null)
              _buildAddImageButton(isFullWidth: true),

            _buildImageThumbnails(),
            _buildVideoPreview(),

            const SizedBox(height: 70), // For FAB or other bottom elements
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
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Text("已选图片:", style: Theme.of(context).textTheme.titleMedium),
        ),
        Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          children: [
            ..._selectedImages.asMap().entries.map((entry) {
              int idx = entry.key;
              XFile imageFile = entry.value;
              return SizedBox(
                width: 100,
                height: 100,
                child: Stack(
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
                      top: 4,
                      right: 4,
                      child: Material(
                        color: Colors.black.withOpacity(0.5),
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () => _removeImage(idx),
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            if (_selectedImages.isNotEmpty &&
                _selectedImages.length < 9 &&
                _selectedVideo == null)
              _buildAddImageButton(),
          ],
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
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Text("已选视频:", style: Theme.of(context).textTheme.titleMedium),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8.0),
                // Potentially add a thumbnail here if you generate one
              ),
              child: const Icon(
                Icons.play_circle_outline_rounded,
                color: Colors.white54,
                size: 60,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.black.withOpacity(0.5),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: _removeVideo,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  _selectedVideo!.name,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
