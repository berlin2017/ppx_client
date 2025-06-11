// StatefulWidget for handling video player state
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppx_client/core/utils/app_logger.dart';
import 'package:video_player/video_player.dart';

import '../core/constants/AppConstants.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerItem({required this.videoUrl});

  @override
  VideoPlayerItemState createState() => VideoPlayerItemState();
}

class VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _controller = VideoPlayerController.networkUrl(Uri.parse(AppConstants.baseUrl + widget.videoUrl));

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller
        .initialize()
        .then((_) {
          // Ensure the first frame is shown after the video is initialized,
          // even before the play button has been pressed.
          if (mounted) {
            setState(() {});
          }
        })
        .catchError((error) {
          // Handle errors during initialization
          AppLogger.error(
            "Error initializing video player: $error for URL ${AppConstants.baseUrl + widget.videoUrl}",
          );
          if (mounted) {
            setState(() {}); // Update UI to show error or placeholder
          }
        });

    _controller.addListener(() {
      if (mounted && _isPlaying != _controller.value.isPlaying) {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      }
    });
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        // If the video is paused or has finished playing, play/replay.
        if (_controller.value.position >= _controller.value.duration) {
          _controller.seekTo(Duration.zero).then((_) => _controller.play());
        } else {
          _controller.play();
        }
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError || !_controller.value.isInitialized) {
            // Display an error message or placeholder if initialization failed
            return AspectRatio(
              aspectRatio: _controller.value.isInitialized
                  ? _controller.value.aspectRatio
                  : 16 / 9,
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            );
          }
          // If the VideoPlayerController has finished initialization, use
          // the VideoPlayer widget to display the video.
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                VideoPlayer(_controller),
                // Play/Pause button
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    color: Colors.transparent, // Make entire area tappable
                    child: Center(
                      child: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color: Colors.white.withOpacity(0.8),
                        size: 60.0,
                      ),
                    ),
                  ),
                ),
                // You can add a VideoProgressIndicator here if needed
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: VideoProgressIndicator(
                //     _controller,
                //     allowScrubbing: true,
                //     padding: EdgeInsets.all(8.0),
                //   ),
                // ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          // Handle error state during initialization phase
          return AspectRatio(
            aspectRatio: 16 / 9, // Default aspect ratio
            child: Container(
              color: Colors.grey[300],
              child: Center(
                child: Text('Error loading video: ${snapshot.error}'),
              ),
            ),
          );
        } else {
          // Otherwise, display a loading indicator.
          return AspectRatio(
            aspectRatio: 16 / 9, // Default aspect ratio while loading
            child: Container(
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }
      },
    );
  }
}
