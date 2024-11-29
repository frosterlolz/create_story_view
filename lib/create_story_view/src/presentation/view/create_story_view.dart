import 'dart:async';
import 'dart:io';

import 'package:create_story_view/create_story_view/src/controller/create_story_controller.dart';
import 'package:create_story_view/create_story_view/src/controller/story_editor_controller.dart';
import 'package:create_story_view/create_story_view/src/model/media_file_entity.dart';
import 'package:create_story_view/create_story_view/src/presentation/view/video_cropper_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../model/story_processing_state.dart';
import '../../utils/story_cache_manager.dart';
import '../widget/story_processing_overlay.dart';

part 'create_story_view_empty.dart';
part 'create_story_view_image.dart';
part 'create_story_view_video.dart';

class CreateStoryView extends StatefulWidget {
  const CreateStoryView({
    this.controller,
    super.key,
  });

  final CreateStoryController? controller;

  @override
  State<CreateStoryView> createState() => CreateStoryViewState();
}

class CreateStoryViewState extends State<CreateStoryView> {
  late final CreateStoryController _controller;

  OverlayEntry? _notificationOverlay;

  static CreateStoryViewState? of(BuildContext context) => context.findAncestorStateOfType<CreateStoryViewState>();

  set notificationOverlay(OverlayEntry overlayEntry) {
    if (_notificationOverlay != null) {
      removeOverlay();
    }
    _notificationOverlay = overlayEntry;
  }

  void removeOverlay() {
    if (_notificationOverlay == null) return;
    _notificationOverlay!.remove();
    _notificationOverlay = null;
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? CreateStoryController();
  }

  void _onDoneTap() {
    // TODO(frosterlolz): implement
  }

  @override
  Widget build(BuildContext context) => StoryControllerProvider(
      controller: _controller,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => switch (_controller.sourceMediaFile?.type) {
          FileType.image => _CreateStoryView$Image(file: _controller.sourceMediaFile!.file, onDone: _onDoneTap),
          FileType.video => _CreateStoryView$Video(file: _controller.sourceMediaFile!.file, onDone: _onDoneTap),
          _ => const _CreateStoryView$Empty()
        },
      ));
}

class StoryControllerProvider extends InheritedWidget {
  const StoryControllerProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  final CreateStoryController controller;

  static StoryControllerProvider of(BuildContext context) {
    final StoryControllerProvider? result = context.dependOnInheritedWidgetOfExactType<StoryControllerProvider>();
    assert(result != null, 'No _StoryControllerInheritedWidget found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(StoryControllerProvider oldWidget) => controller != oldWidget.controller;
}
