part of 'create_story_view.dart';

const _itemMaxSecondsDuration = 15;

class _CreateStoryView$Video extends StatefulWidget {
  const _CreateStoryView$Video({required this.file, required this.onDone});

  final File file;
  final VoidCallback onDone;

  @override
  State<_CreateStoryView$Video> createState() => _CreateStoryView$VideoState();
}

class _CreateStoryView$VideoState extends State<_CreateStoryView$Video> {
  late final StoryEditorController _storyEditorController;

  @override
  void initState() {
    super.initState();
    _storyEditorController = StoryEditorController(
      sourceFile: widget.file,
      maxItemDuration: const Duration(seconds: _itemMaxSecondsDuration),
    )..initialize().then((_) {
      setState(() {});
    });
  }

  void _onBackTap(BuildContext context) {
    StoryControllerProvider.of(context).controller.changeFile(null);
  }

  Future<void> _onDoneTap() async {
    final controllerInitialized = _storyEditorController.isInitialized;
    if (!controllerInitialized) return;
    final processingStateNotifier = ValueNotifier(
      const StoryProcessingState(
        totalSteps: 1,
        currentStep: 1,
        message: '',
      ),
    );
    CreateStoryViewState.of(context)?.notificationOverlay = showStoryProcessingOverlay(
      context,
      processingNotifier: processingStateNotifier,
    );
    final exportingCompleter = Completer<void>();
    await _storyEditorController.exportStory(
      progressNotifier: processingStateNotifier,
      onSuccess: (files) {
        processingStateNotifier.value = processingStateNotifier.value.copyWith(
          message: 'Files exported successfully',
          status: StoryProcessingStatus.success,
        );
        exportingCompleter.complete();
        StoryControllerProvider.of(context).controller.changeSeparatedFiles(
              files,
              forceMimeType: 'video/mp4',
            );
        widget.onDone.call();
      },
      onError: (e, s) {
        processingStateNotifier.value = processingStateNotifier.value.copyWith(
          message: 'Exporting video failed',
          status: StoryProcessingStatus.error,
        );
        exportingCompleter.complete();
      },
    );
    await exportingCompleter.future;
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    CreateStoryViewState.of(context)?.removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    final controller = StoryControllerProvider.of(context).controller;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
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
                onPressed: _onDoneTap,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Share'),
              ),
            ),
          ],
        ),
      ),
      body: _storyEditorController.isInitialized
          ? VideoCropperView(storyEditorController: _storyEditorController)
          : const Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
