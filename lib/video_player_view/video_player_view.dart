import 'dart:io';

import 'package:create_story_view/create_story_view/src/model/media_file_entity.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({super.key});

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  VideoPlayerController? _controller;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
  }

  Future<void> _onRefreshTap() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    await _controller!.pause();
    await _controller!.dispose();
    _controller = null;
    setState(() {});
  }

  Future<void> _updateVideo() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final file = await _pickVideo();
      if (file == null) return;
      await _initController(file);
    } finally {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  Future<File?> _pickVideo() async {
    final file = await ImagePicker().pickMedia();
    if (file == null) return null;
    return File(file.path);
  }

  Future<void> _initController(File file) async {
    final mimeType = lookupMimeType(file.path);
    if (FileType.fromMime(mimeType) != FileType.video) {
      return;
    }
    _controller ??= VideoPlayerController.file(file);
    await _controller!.initialize();
    if (!mounted) return;
    setState(() {

      _controller!.play();
    });
  }

  void _testCallback() {
    setState(() {
      _controller!.value = _controller!.value.copyWith(
        size: Size(_controller!.value.size.height, _controller!.value.size.width),
        rotationCorrection: 90,
      );
      print(_controller!.value.size);
    });
  }

  Future<void> _pause() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    _controller!.value.isPlaying ? await _controller!.pause() : _controller!.play();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: const Text('Video viewer'),
            actions: [
              IconButton(onPressed: _testCallback, icon: const Icon(Icons.abc)),
              IconButton(onPressed: _onRefreshTap, icon: const Icon(Icons.refresh)),
            ],
            bottom: _controller == null || !_controller!.value.isInitialized
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(kToolbarHeight),
                    child: Wrap(
                      spacing: 5.0,
                      children: [
                        Text('video size: ${_controller!.value.size}'),
                        Text('aspect ratio: ${_controller!.value.aspectRatio}'),
                        Text('rotation correction: ${_controller!.value.rotationCorrection}'),
                      ],
                    ),
                  )),
        body: switch (_controller) {
          _ when _isLoading => const Center(child: CircularProgressIndicator()),
          _ when _controller != null && _controller!.value.isInitialized => GestureDetector(
              onTap: _pause,
              child: Placeholder(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(
                    _controller!,
                  ),
                ),
              ),
            ),
          _ => Center(
              child: ElevatedButton(onPressed: _updateVideo, child: const Text('Pick video')),
            )
        },
      );
}
