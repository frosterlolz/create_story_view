import 'package:create_story_view/create_story_view/create_story_view.dart';
import 'package:create_story_view/create_story_view/src/controller/story_editor_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_editor/video_editor.dart';

import '../widget/story_notification_overlay.dart';
import '../widget/video_trim_slider.dart';

class VideoCropperView extends StatefulWidget {
  const VideoCropperView({
    required this.storyEditorController,
    super.key,
  });

  final StoryEditorController storyEditorController;

  @override
  State<VideoCropperView> createState() => _VideoCropperViewState();
}

class _VideoCropperViewState extends State<VideoCropperView> {
  late final ValueNotifier<double> _exportingProgressNotifier;
  late final ValueNotifier<bool> _isExportingNotifier;

  @override
  void initState() {
    super.initState();
    _exportingProgressNotifier = ValueNotifier<double>(0.0);
    _isExportingNotifier = ValueNotifier<bool>(false);
  }

  VideoEditorController get _videoEditorController => widget.storyEditorController.videoEditorController;

  Future<void> _muteVolume() async {
    if (widget.storyEditorController.isMuted) {
      await widget.storyEditorController.unMute();
    } else {
      await widget.storyEditorController.mute();
    }
    if (!mounted) return;
    if (widget.storyEditorController.isMuted) {
      CreateStoryViewState.of(context)?.notificationOverlay = showStoryNotificationOverlay(
        context,
        message: 'Video will be without sound',
      );
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      CreateStoryViewState.of(context)?.removeOverlay();
    }
  }

  @override
  void dispose() {
    _exportingProgressNotifier.dispose();
    _isExportingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: Center(
                      child: CropGridViewer.preview(
                        controller: widget.storyEditorController.videoEditorController,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (widget.storyEditorController.isInitialized)
                  VideoTrimSlider(videoEditorController: _videoEditorController),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Positioned(
            bottom: MediaQuery.sizeOf(context).height * 0.2,
            right: 10,
            child: CircleAvatar(
              child: IconButton(
                icon: ListenableBuilder(
                  listenable: widget.storyEditorController,
                  builder: (context, _) => Icon(
                    !widget.storyEditorController.isMuted ? Icons.volume_up : Icons.volume_mute_outlined,
                  ),
                ),
                onPressed: _muteVolume,
              ),
            ),
          ),
          if (kDebugMode)
            Positioned(
              top: kToolbarHeight + 30,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.storyEditorController.videoEditorController.videoDimension}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Rotation correction: ${widget.storyEditorController.videoEditorController.video.value.rotationCorrection}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      );
}
