import 'package:flutter/material.dart';

OverlayEntry showStoryNotificationOverlay(
  BuildContext context, {
  required String message,
}) {
  final entry = OverlayEntry(
    builder: (context) => _NotificationOverlayBody(message: message),
  );
  Overlay.of(context).insert(entry);
  return entry;
}

class _NotificationOverlayBody extends StatelessWidget {
  const _NotificationOverlayBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.center,
        child: Material(
          color: Colors.black87,
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
}
