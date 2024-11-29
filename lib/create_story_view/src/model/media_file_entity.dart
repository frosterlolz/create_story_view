import 'dart:io';

import 'package:flutter/material.dart';

enum FileType {
  image,
  video,
  other;

  factory FileType.fromMime(String? mime) => switch (mime?.split('/').first) {
        'image' => FileType.image,
        'video' => FileType.video,
        _ => FileType.other,
      };
}

@immutable
class MediaFileEntity implements Comparable<MediaFileEntity> {
  const MediaFileEntity({
    required this.file,
    required this.name,
    required this.mimeType,
    required this.lastModified,
  });

  // factory MediaFileEntity.fromTable(MediaFilesTableData tableData) => MediaFileEntity(
  //     file: file,
  //     name: name,
  //     mimeType: mimeType,
  // );

  final DateTime lastModified;
  final File file;
  final String name;
  final String mimeType;

  FileType get type => FileType.fromMime(mimeType);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaFileEntity &&
          runtimeType == other.runtimeType &&
          file == other.file &&
          name == other.name &&
          mimeType == other.mimeType;

  @override
  int get hashCode => file.hashCode ^ name.hashCode ^ mimeType.hashCode;

  @override
  int compareTo(MediaFileEntity other) => name.compareTo(other.name);
  //lastModified.compareTo(other.lastModified);
}
