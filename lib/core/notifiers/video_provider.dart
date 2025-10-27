import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoProvider with ChangeNotifier {
  VideoPlayerController? controller;
  bool isInitialized = false;
  bool isPlaying = false;
  String? currentVideoUrl;

  Future<void> initializeVideo(String url) async {
    currentVideoUrl = url;
    controller?.dispose();
    controller = VideoPlayerController.networkUrl(Uri.parse(url));

    // Add listener to detect when video completes
    controller!.addListener(_videoListener);

    await controller!.initialize();
    isInitialized = true;
    isPlaying = false;
    notifyListeners();
  }

  void _videoListener() {
    if (controller == null) return;

    // Check if video has reached the end
    if (controller!.value.position >= controller!.value.duration &&
        controller!.value.duration > Duration.zero) {
      _handleVideoCompletion();
    }
  }

  void _handleVideoCompletion() {
    if (controller == null) return;

    // Pause the video and seek to beginning
    controller!.pause();
    controller!.seekTo(Duration.zero);

    isPlaying = false;
    notifyListeners();
  }

  void playPause() {
    if (controller == null) return;

    if (controller!.value.isPlaying) {
      controller!.pause();
      isPlaying = false;
    } else {
      controller!.play();
      isPlaying = true;

      // Check if video is at the end, if so, restart from beginning
      if (controller!.value.position >= controller!.value.duration &&
          controller!.value.duration > Duration.zero) {
        controller!.seekTo(Duration.zero);
      }
    }
    notifyListeners();
  }

  void disposeController() {
    // Remove listener before disposing
    controller?.removeListener(_videoListener);
    controller?.dispose();
    controller = null;
    isInitialized = false;
    isPlaying = false;
    currentVideoUrl = null;
    notifyListeners();
  }
}
