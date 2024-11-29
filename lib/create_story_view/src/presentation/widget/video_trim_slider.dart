import 'package:flutter/material.dart';
import 'package:video_editor/video_editor.dart';

const _trimSliderHeight = 60.0;

class VideoTrimSlider extends StatelessWidget {
  const VideoTrimSlider({
    required this.videoEditorController,
    super.key,
  });

  final VideoEditorController videoEditorController;

  String _formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0'),
      ].join(':');

  @override
  Widget build(BuildContext context) => Column(
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([
              videoEditorController,
              videoEditorController.video,
            ]),
            builder: (_, __) {
              final int duration = videoEditorController.videoDuration.inSeconds;
              final double pos = videoEditorController.trimPosition * duration;

              return Padding(
                padding: EdgeInsets.zero, //.symmetric(horizontal: height / 4),
                child: Row(
                  children: [
                    Text(
                      _formatter(Duration(seconds: pos.toInt())),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    AnimatedOpacity(
                      opacity: videoEditorController.isTrimming ? 1 : 0,
                      duration: kThemeAnimationDuration,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatter(videoEditorController.startTrim),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _formatter(videoEditorController.endTrim),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Container(
            width: MediaQuery.sizeOf(context).width,
            padding: const EdgeInsets.symmetric(vertical: _trimSliderHeight / 4),
            child: TrimSlider(
              controller: videoEditorController,
              height: _trimSliderHeight,
              horizontalMargin: _trimSliderHeight / 4,
              child: TrimTimeline(
                textStyle: const TextStyle(
                  color: Colors.white,
                ),
                localSeconds: 'с',
                controller: videoEditorController,
                padding: const EdgeInsets.only(top: 10),
              ),
            ),
          ),
        ],
      );
}
