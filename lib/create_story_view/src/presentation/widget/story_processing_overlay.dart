import 'package:create_story_view/create_story_view/src/model/story_processing_state.dart';
import 'package:flutter/material.dart';

OverlayEntry showStoryProcessingOverlay(
  BuildContext context, {
  required ValueNotifier<StoryProcessingState> processingNotifier,
}) {
  final entry = OverlayEntry(
    builder: (context) => _NotificationOverlayBody(processingNotifier: processingNotifier),
  );
  Overlay.of(context).insert(entry);
  return entry;
}

class _NotificationOverlayBody extends StatelessWidget {
  const _NotificationOverlayBody({required this.processingNotifier});

  final ValueNotifier<StoryProcessingState> processingNotifier;

  @override
  Widget build(BuildContext context) {
    const messageStyle = TextStyle(color: Colors.white);
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Material(
          color: Colors.black87,
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ValueListenableBuilder(
              valueListenable: processingNotifier,
              builder: (context, processingState, child) => switch (processingState.status) {
                StoryProcessingStatus.processing || StoryProcessingStatus.success => TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 200),
                    tween: Tween<double>(
                      begin: 0.0,
                      end: processingState.status == StoryProcessingStatus.success ? 1.0 : processingState.progress,
                    ),
                    builder: (context, double currentProgress, child) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (processingState.message != null)
                          Text('${processingState.message!} ${processingState.currentStep}', style: messageStyle),
                        const SizedBox(height: 8.0),
                        LinearProgressIndicator(
                          value: currentProgress,
                        ),
                      ],
                    ),
                  ),
                StoryProcessingStatus.error => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(processingState.message ?? 'Something went wrong', style: messageStyle),
                    ],
                  ),
              },
            ),
          ),
        ),
      ),
    );
  }
}
