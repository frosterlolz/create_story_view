import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:create_story_view/create_story_view/src/utils/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:video_editor/video_editor.dart';

import '../model/story_processing_state.dart';
import '../utils/ffmpeg_service.dart';
import '../utils/story_cache_manager.dart';

const _fallbackDuration = Duration(seconds: 1);
const _minStoryItemSeconds = 1;
const _maxStoriesInARow = 10;
const _itemMaxSecondsDuration = 15;

int get _maxStorySeconds => _itemMaxSecondsDuration * _maxStoriesInARow;

class StoryEditorController with ChangeNotifier {
  StoryEditorController({
    required File sourceFile,
    Duration minItemDuration = const Duration(seconds: _minStoryItemSeconds),
    Duration? maxItemDuration,
    int maxStoryParts = _maxStoriesInARow,
  })  : _fFmpegService = FFmpegService(),
        _videoEditorController = VideoEditorController.file(
          sourceFile,
          minDuration: minItemDuration,
          maxDuration: Duration(
            seconds: maxItemDuration == null ? _maxStorySeconds : maxItemDuration.inSeconds * maxStoryParts,
          ),
        ),
        _maxItemDuration = maxItemDuration;

  final FFmpegService _fFmpegService;

  final VideoEditorController _videoEditorController;

  /// max story item duration (prefer in seconds)
  final Duration? _maxItemDuration;

  VideoEditorController get videoEditorController => _videoEditorController;

  bool get isMuted => _videoEditorController.video.value.volume == 0.0;

  bool get isInitialized => _videoEditorController.initialized;

  Future<void> initialize([double? aspectRatio]) async {
    await _videoEditorController.initialize(aspectRatio: aspectRatio);
    final videoDuration = _videoEditorController.video.value.duration;
    _videoEditorController.maxDuration = _videoEditorController.maxDuration.clamp(_fallbackDuration, videoDuration);
    notifyListeners();
  }

  Future<void> unMute() async {
    _fFmpegService.sessions.removeWhere((k, v) => k == VideoEditorOptions.volume);
    await _videoEditorController.video.setVolume(1.0);
    notifyListeners();
  }

  Future<void> mute() async {
    _fFmpegService.sessions[VideoEditorOptions.volume] = 'volume';
    await _videoEditorController.video.setVolume(0.0);
    notifyListeners();
  }

  Future<void> play() => _videoEditorController.video.play();

  Future<void> pause() => _videoEditorController.video.pause();

  Future<void> exportStory({
    required ValueNotifier<StoryProcessingState> progressNotifier,
    required ValueChanged<List<File>> onSuccess,
    required void Function(Object error, StackTrace? stackTrace) onError,
  }) async {
    try {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        pause();
      });
      final sourceVideoDuration = _videoEditorController.video.value.duration;
      // TODO(fix): handle error (controller not initialized)
      if (sourceVideoDuration == Duration.zero) return;

      final outputDirectory = await StoryCacheManager.getCachePath(
        repositoryType: StoryCachingKeys.separatedFiles,
      );
      final List<VideoFFmpegVideoEditorConfig> exportingSteps =
          _configureExportingSteps(_maxItemDuration, outputDirectory);

      final files = await _exportFiles(
        exportingSteps,
        onProgress: (progressState) => progressNotifier.value = progressState,
      ).timeout(const Duration(minutes: 2));

      onSuccess.call(files);
    } on Object catch (e, s) {
      dev.log(e.toString(), stackTrace: s);

      onError.call(e, s);
    }
  }

  Future<List<File>> _exportFiles(
    List<VideoFFmpegVideoEditorConfig> configuredSteps, {
    void Function(StoryProcessingState)? onProgress,
  }) async {
    final files = <File>[];

    final totalSteps = configuredSteps.length;
    var currentStep = 0;
    for (final step in configuredSteps) {
      final percent = (currentStep * 100 ~/ totalSteps).clamp(0, 100);
      dev.log('Exporting ${currentStep + 1} file. Progress: $percent%');
      // onProgress?.call(percent, 'Exporting ${currentStep + 1} file');
      // TODO(add): add error handler
      final file = await _fFmpegService.exportFile(
        step,
        onProgress: (statistics) {
          final currentProgress = step.getFFmpegProgress(statistics.getTime().toInt());
          final storyProcessingState = StoryProcessingState(
            totalSteps: totalSteps,
            currentStep: currentStep + 1,
            message: 'Files.preparing %s story',
            stepProgress: currentProgress,
          );
          dev.log(
            'FileNumber: ${storyProcessingState.currentStep} Overall progress: ${storyProcessingState.progress}',
          );
          onProgress?.call(storyProcessingState);
        },
      );

      files.add(file);
      currentStep++;
    }

    return files;
  }

  List<VideoFFmpegVideoEditorConfig> _configureExportingSteps(
    Duration? stepDuration,
    String? outputDirectory,
  ) {
    final outputSteps = <VideoFFmpegVideoEditorConfig>[];

    int index = 0;
    Duration lowerBound = _videoEditorController.startTrim;
    final upperBound = _videoEditorController.endTrim;
    while (lowerBound < upperBound) {
      final nextEndTrim = stepDuration == null
          ? upperBound
          : (lowerBound + stepDuration).clamp(Duration.zero, _videoEditorController.endTrim);

      debugPrint('Step config with: startTrim: $lowerBound, endTrim: $nextEndTrim');
      final videoConfig = _fFmpegService.createConfig(
        videoEditorController: _videoEditorController,
        startTrim: lowerBound,
        partDuration: stepDuration ?? upperBound,
        fileName: 'story_item_$index',
        outputDirectory: outputDirectory,
      );

      lowerBound = nextEndTrim;
      index++;

      outputSteps.add(videoConfig);
    }

    return outputSteps;
  }

  @mustCallSuper
  @override
  void dispose() {
    _videoEditorController.dispose();
    _fFmpegService.dispose();
    super.dispose();
  }
}
