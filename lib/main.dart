import 'dart:async';

import 'package:create_story_view/video_player_view/video_player_view.dart';
import 'package:flutter/material.dart';

void main() {
  runZonedGuarded(() => runApp(const App()), (e, s) {
    debugPrint('$e\n$s');
  });
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
    home: const VideoPlayerView(),
    // home: const CreateStoryView(),
    // home: Scaffold(
    //   body: Center(child: Text('SAMPLE')),
    // ),
  );
}
