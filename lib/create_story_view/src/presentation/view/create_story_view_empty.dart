part of 'create_story_view.dart';

class _CreateStoryView$Empty extends StatefulWidget {
  const _CreateStoryView$Empty({this.message});

  final String? message;

  @override
  State<_CreateStoryView$Empty> createState() => _CreateStoryView$EmptyState();
}

class _CreateStoryView$EmptyState extends State<_CreateStoryView$Empty> {
  late final ImagePicker _imagePicker;
  String? _errorMessage;
  late bool _isLoading;

  @override
  void initState() {
    _errorMessage = widget.message;
    super.initState();
    _isLoading = false;
    _imagePicker = ImagePicker();

    // _pickMedia();
  }

  @override
  void didUpdateWidget(covariant _CreateStoryView$Empty oldWidget) {
    if (oldWidget.message != widget.message) {
      setState(() {
        _errorMessage = widget.message;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _pickMedia() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await StoryCacheManager.clearCache();
      final stopWatch = Stopwatch()..start();
      final pickedXFile = await _imagePicker.pickMedia();
      stopWatch.stop();
      debugPrint('Image picked in ${stopWatch.elapsedMilliseconds} ms');
      if (pickedXFile == null) return;
      final cachedFile = await StoryCacheManager.saveToCache(
        File(pickedXFile.path),
        forceFileName: 'story_source_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (cachedFile == null) return;
      final cachedXFile = XFile(cachedFile.path);
      if (!mounted) return;
      StoryControllerProvider.of(context).controller.changeFile(cachedXFile);
    } on Object catch (e, s) {
      debugPrint('$e\n$s');
      setState(() {
        _errorMessage = 'Error while selecting media file';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
                onPressed: Navigator.of(context).pop,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Back'),
              ),
              const Spacer(),
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10.0),
              ],
              if (_isLoading)
                const CircularProgressIndicator.adaptive(backgroundColor: Colors.white)
              else
                OutlinedButton(
                  onPressed: _pickMedia,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                  child: Text(_errorMessage == null ? 'Загрузить историю' : 'Повторить'),
                ),
            ],
          ),
        ),
      );
}
