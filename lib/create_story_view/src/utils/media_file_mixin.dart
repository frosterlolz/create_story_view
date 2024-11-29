import 'dart:io';

import 'package:mime/mime.dart';

import '../model/media_file_entity.dart';
import 'package:image_picker/image_picker.dart';

import 'extensions.dart';

mixin MediaFileMixin {
  MediaFileEntity xFileToMediaFileConvert(XFile xFile) {
    final mimeType = xFile.mimeType ?? lookupMimeType(xFile.path);
    if (mimeType == null) {
      throw MediaFileConverterExtension(message: 'Errors.File not supported');
    }
    final file = File(xFile.path);
    final mediaFile = MediaFileEntity(
      file: File(xFile.path),
      mimeType: mimeType,
      name: xFile.name,
      lastModified: file.lastModifiedSync(),
    );

    return mediaFile;
  }
}