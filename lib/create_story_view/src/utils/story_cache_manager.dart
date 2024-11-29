import 'dart:developer';
import 'dart:io' as io;

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

enum StoryCachingKeys {
  parent('story_media_files'),
  sourceFiles('story_media_files/source'),
  separatedFiles('story_media_files/separated');

  const StoryCachingKeys(this.name);
  final String name;
}

abstract class StoryCacheManager {
  StoryCacheManager();

  static Future<String?> getCachePath({
    StoryCachingKeys repositoryType = StoryCachingKeys.sourceFiles,
    String? fileName,
  }) async {
    try {
      final cacheDirectory = await getTemporaryDirectory();
      String outputDirectory = '${cacheDirectory.path}/${repositoryType.name}';

      final directoryAlreadyExists = io.Directory(outputDirectory).existsSync();
      if (!directoryAlreadyExists) {
        await io.Directory(outputDirectory).create(recursive: true);
      }

      if (fileName != null) {
        outputDirectory = '$outputDirectory/$fileName';
      }

      return outputDirectory;
    } on Object catch (e, s) {
      log('$e\n$s');
      return null;
    }
  }

  static Future<io.File?> saveToCache(
    io.File file, {
    StoryCachingKeys repositoryType = StoryCachingKeys.sourceFiles,
    String? forceFileName,
  }) async {
    final cacheDir = await getCachePath();
    if (cacheDir == null) return null;
    final updatedFileName = '${forceFileName ?? basenameWithoutExtension(file.path)}.${extension(file.path)}';
    final cachedFile = await file.copy('$cacheDir/$updatedFileName');
    return cachedFile;
  }

  static Future<List<io.File>?> loadCachedFiles(StoryCachingKeys type) async {
    final cachePath = await StoryCacheManager.getCachePath(repositoryType: type);
    if (cachePath == null) return null;
    final files = io.Directory(cachePath).listSync();
    return files.map((e) => io.File(e.path)).toList();
  }

  static Future<void> clearCache() async {
    final cachePath = await StoryCacheManager.getCachePath(
      repositoryType: StoryCachingKeys.parent,
    );
    if (cachePath == null) return;
    await io.Directory(cachePath).delete(recursive: true);
  }
}
