import 'dart:io';

import 'package:create_story_view/create_story_view/src/model/media_file_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/media_file_mixin.dart';

final class CreateStoryController with MediaFileMixin, ChangeNotifier implements ICreateStoryController {
  CreateStoryController();

  @override
  MediaFileEntity? sourceMediaFile;
  @override
  List<MediaFileEntity>? separatedMediaFiles;

  @override
  void changeFile(XFile? xFile) {
    sourceMediaFile = xFile == null ? null : xFileToMediaFileConvert(xFile);
    notifyListeners();
  }

  @override
  void changeSeparatedFiles(List<File>? files, {String? forceMimeType}) {
    if (sourceMediaFile == null) {
      throw Exception('Source media file is null');
    }
    if (files?.isEmpty ?? true) {
      separatedMediaFiles = null;
      notifyListeners();
      return;
    }
    separatedMediaFiles = files!.map(
          (file) => MediaFileEntity(
        file: file,
        name: file.path.split('/').last,
        mimeType: forceMimeType ?? sourceMediaFile!.mimeType,
        lastModified: file.lastModifiedSync(),
      ),
    )
        .toList();
  }
}

abstract interface class ICreateStoryController {
  MediaFileEntity? get sourceMediaFile;
  List<MediaFileEntity>? get separatedMediaFiles;

  void changeFile(XFile xFile);
  void changeSeparatedFiles(List<File> files, {String? forceMimeType});
}
