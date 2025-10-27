import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../core/notifiers/video_provider.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final double height;
  final double borderRadius;
  final double playIconSize;
  final double controlIconSize;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.height = 220,
    this.borderRadius = 8,
    this.playIconSize = 64,
    this.controlIconSize = 48,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  Uint8List? _thumbnail;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    final thumb = await VideoThumbnail.thumbnailData(
      video: widget.videoUrl,
      imageFormat: ImageFormat.JPEG,
      quality: 75,
    );
    if (mounted) {
      setState(() {
        _thumbnail = thumb;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoProvider>(
      builder: (context, videoProv, child) {
        final bool isCurrentVideo =
            videoProv.currentVideoUrl == widget.videoUrl;
        final bool showVideoPlayer = isCurrentVideo && videoProv.isInitialized;

        return GestureDetector(
          onTap: () => _handleVideoTap(videoProv, isCurrentVideo),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: showVideoPlayer
                ? _buildVideoPlayer(videoProv)
                : _buildPlaceholder(),
          ),
        );
      },
    );
  }

  Future<void> _handleVideoTap(
    VideoProvider videoProv,
    bool isCurrentVideo,
  ) async {
    if (!isCurrentVideo) {
      await videoProv.initializeVideo(widget.videoUrl);
    }
    videoProv.playPause();
  }

  Widget _buildVideoPlayer(VideoProvider videoProv) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: videoProv.controller!.value.aspectRatio,
          child: VideoPlayer(videoProv.controller!),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: IconButton(
            icon: Icon(
              videoProv.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_fill,
              size: widget.controlIconSize,
              color: Colors.white,
            ),
            onPressed: () => videoProv.playPause(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return _thumbnail != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.memory(
                  _thumbnail!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: widget.height,
                ),
                Icon(Icons.play_circle_fill, size: 64, color: Colors.white70),
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
