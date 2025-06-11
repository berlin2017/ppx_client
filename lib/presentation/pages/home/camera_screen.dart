// lib/presentation/pages/home/camera_screen.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import '../common/display_picture_screen.dart'; // 引入 DisplayPictureScreen

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  CameraDescription? _selectedCamera; // To store the selected camera

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isEmpty) {
      // Handle no cameras available
      print("没有可用的摄像头!");
      // You might want to pop or show a message
      return;
    }
    _selectedCamera = widget.cameras.first; // Default to the first camera
    _initializeCamera();
  }

  void _initializeCamera() {
    if (_selectedCamera == null) return;

    _controller = CameraController(
      _selectedCamera!,
      ResolutionPreset.high, // 可以根据需要调整分辨率
    );
    _initializeControllerFuture = _controller
        .initialize()
        .then((_) {
          if (!mounted) {
            return;
          }
          setState(() {}); // Update the UI once initialized
        })
        .catchError((Object e) {
          if (e is CameraException) {
            switch (e.code) {
              case 'CameraAccessDenied':
                print('用户拒绝了相机访问权限。');
                // Handle access errors here.
                break;
              default:
                print('处理相机错误: ${e.description}');
                // Handle other errors here.
                break;
            }
          }
        });
  }

  void _toggleCamera() {
    if (widget.cameras.length < 2) {
      print("只有一个摄像头，无法切换。");
      return;
    }
    final CameraDescription newCamera =
        (_selectedCamera == widget.cameras.first)
        ? widget.cameras.last
        : widget.cameras.first;

    if (_controller.value.isStreamingImages) {
      _controller.stopImageStream();
    }
    _controller.dispose().then((_) {
      setState(() {
        _selectedCamera = newCamera;
        _initializeCamera();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      // 确保控制器已初始化
      await _initializeControllerFuture;

      // 构建图片保存的路径
      final String path = join(
        (await getTemporaryDirectory()).path, // 使用临时目录
        '${DateTime.now().millisecondsSinceEpoch}.png',
      );

      // 尝试拍摄照片并获取文件 `XFile`，其中包含路径
      final XFile picture = await _controller.takePicture();

      // 如果照片拍摄成功，则导航到 DisplayPictureScreen
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(imagePath: picture.path),
        ),
      );
    } catch (e) {
      // 如果发生错误，记录到控制台
      print("拍摄照片时发生错误: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cameras.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('拍照')),
        body: const Center(child: Text('没有可用的摄像头')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('拍照'),
        actions: [
          if (widget.cameras.length >
              1) // Only show toggle if more than one camera
            IconButton(
              icon: const Icon(Icons.switch_camera),
              onPressed: _toggleCamera,
              tooltip: "切换摄像头",
            ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!_controller.value.isInitialized) {
              return const Center(child: Text('无法初始化摄像头'));
            }
            // 如果 Future 完成，显示预览
            return CameraPreview(_controller);
          } else {
            // 否则，显示加载指示器
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
