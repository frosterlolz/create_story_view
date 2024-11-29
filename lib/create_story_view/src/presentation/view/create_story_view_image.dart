part of 'create_story_view.dart';

class _CreateStoryView$Image extends StatelessWidget {
  const _CreateStoryView$Image({
    required this.file,
    required this.onDone,
  });

  final File file;
  final VoidCallback onDone;

  void _onBackTap(BuildContext context) {
    final createStoryController = StoryControllerProvider.of(context).controller;
    if (createStoryController.sourceMediaFile == null) {
      Navigator.of(context).pop();
    } else {
      createStoryController.changeFile(null);
    }
  }

  Future<void> _onDoneTap(BuildContext context) async {
    final cachedPath = await StoryCacheManager.getCachePath(
      repositoryType: StoryCachingKeys.sourceFiles,
      fileName: path.basename(file.path),
    );
    final separatedFile = await file.rename(cachedPath ?? file.path);
    if (!context.mounted) return;
    StoryControllerProvider.of(context).controller.changeSeparatedFiles([separatedFile]);
    onDone.call();
  }

  @override
  Widget build(BuildContext context) {
    final controller = StoryControllerProvider.of(context).controller;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () => _onBackTap(context),
              child: const Text('Cancel'),
            ),
            const Spacer(),
            ListenableBuilder(
              listenable: controller,
              builder: (context, child) =>
                  (controller.separatedMediaFiles?.isEmpty ?? true) ? const SizedBox.shrink() : child!,
              child: TextButton(
                onPressed: () => _onDoneTap(context),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Share'),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const Spacer(),
          Image.file(file),
          const Spacer(),
        ],
      ),
    );
  }
}
