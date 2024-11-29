class MediaFileConverterExtension implements Exception {
  MediaFileConverterExtension({required this.message});

  final String message;

  @override
  String toString() => 'MediaFileConverterExtension(message: $message)';
}

extension XDuration on Duration {
  Duration clamp(Duration min, Duration max) => Duration(
    milliseconds: inMilliseconds.clamp(min.inMilliseconds, max.inMilliseconds),
  );
}