import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter/statistics.dart';
import 'package:flutter/material.dart';
import 'package:video_editor/video_editor.dart';

final class FFmpegService implements IFFmpegService {
  FFmpegService({
    this.maxVideoDuration,
    this.maxVideoResolution = const Size(1920, 1920),
  }) : sessions = {};

  final Duration? maxVideoDuration;
  final Size? maxVideoResolution;

  /// selected option and sessionID
  final Map<VideoEditorOptions, String> sessions;

  @override
  Future<File> exportFile(
    VideoFFmpegVideoEditorConfig config, {
    ValueChanged<Statistics>? onProgress,
    void Function(Object, StackTrace)? onError,
  }) async {
    final Completer<File> executionCompleter = Completer();
    final videoEditorExecute = await config.getExecuteConfig();
    final session = await runFFmpegCommand(
      videoEditorExecute,
      onProgress: onProgress,
      onCompleted: executionCompleter.complete,
      onError: onError,
    );
    dev.log(
      'Session: ${session.getSessionId()} is: ${await session.getReturnCode()}',
    );

    return executionCompleter.future;
  }

  @override
  VideoFFmpegVideoEditorConfig createConfig({
    required VideoEditorController videoEditorController,
    required Duration startTrim,
    required Duration partDuration,
    String? fileName,
    String? outputDirectory,
  }) {
    final trimLowerBound = '-ss $startTrim';
    final trimUpperBound = '-t $partDuration';
    final filters = sessions.keys.map((e) => e.command).join(' ');

    final config = VideoFFmpegVideoEditorConfig(
      videoEditorController,
      name: fileName,
      format: VideoExportFormat.mp4,
      outputDirectory: outputDirectory,
      commandBuilder: (config, videoPath, outputPath) {
        // TODO(frosterlolz): add if it will be necessary
        // final List<String> filtersFromController = config.getExportFilters();

        final baseCommand = '$trimLowerBound $trimUpperBound -i $videoPath';
        final inputResolution = videoEditorController.video.value.size;
        final resolution = maxVideoResolution == null ? null : _adjustResolution(inputResolution, maxVideoResolution!);
        final resolutionCommand = resolution == null ? '' : ' $resolution';
        const copyCommand = ' -c:a copy';
        final filtersCommand = filters.isEmpty ? '' : ' $filters';

        final command = '$baseCommand$resolutionCommand$copyCommand$filtersCommand $outputPath';

        return command;
      },
    );

    return config;
  }

  static Future<FFmpegSession> runFFmpegCommand(
    FFmpegVideoEditorExecute execute, {
    required void Function(File file) onCompleted,
    void Function(Object, StackTrace)? onError,
    void Function(Statistics)? onProgress,
  }) {
    dev.log('FFmpeg start process with command = ${execute.command}');
    return FFmpegKit.executeAsync(
      execute.command,
      (session) async {
        final state = FFmpegKitConfig.sessionStateToString(await session.getState());
        final code = await session.getReturnCode();

        if (ReturnCode.isSuccess(code)) {
          onCompleted(File(execute.outputPath));
        } else {
          if (onError != null) {
            onError(
              Exception(
                'FFmpeg process exited with state $state and return code $code.\n${await session.getOutput()}',
              ),
              StackTrace.current,
            );
          }
          return;
        }
      },
      null,
      onProgress,
    );
  }

  @override
  Future<void> dispose() async {
    final executions = await FFmpegKit.listSessions();
    if (executions.isNotEmpty) await FFmpegKit.cancel();
  }

  String? _adjustResolution(Size inputResolution, Size maxResolution) {
    // Если входное разрешение меньше или равно максимальному, возвращаем его
    if (inputResolution <= maxResolution) return null;

    // Вычисляем коэффициенты масштабирования по ширине и по высоте
    final double widthRatio = maxResolution.width / inputResolution.width;
    final double heightRatio = maxResolution.height / inputResolution.height;

    // Выбираем минимальный коэффициент, чтобы обе стороны уместились в maxDefinition
    final double scale = min(heightRatio, widthRatio);

    // Вычисляем новое разрешение с сохранением соотношения сторон
    final double newWidth = inputResolution.width * scale;
    final double newHeight = inputResolution.height * scale;

    final updatedDefinition = Size(newWidth, newHeight);

    return '-vf scale=${updatedDefinition.width.toInt()}:${updatedDefinition.height.toInt()}';
  }
}

abstract interface class IFFmpegService {
  VideoFFmpegVideoEditorConfig createConfig({
    required VideoEditorController videoEditorController,
    required Duration startTrim,
    required Duration partDuration,
    String? fileName,
  });

  Future<File> exportFile(
    VideoFFmpegVideoEditorConfig config, {
    ValueChanged<Statistics>? onProgress,
    void Function(Object, StackTrace)? onError,
  });

  @mustCallSuper
  Future<void> dispose();
}

enum VideoEditorOptions {
  volume('-an');

  const VideoEditorOptions(this.command);

  final String command;
}
