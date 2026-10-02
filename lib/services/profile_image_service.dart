import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ProfileImageService {
  final Dio dio;

  ProfileImageService(this.dio);

  Future<String?> downloadAndSave(String imageUrl) async {
    if (imageUrl.isEmpty) return null;

    try {
      final directory = await getApplicationDocumentsDirectory();

      final filePath = '${directory.path}/profile_avatar.jpg';

      await dio.download(
        imageUrl,
        filePath,
      );

      if (await File(filePath).exists()) {
        return filePath;
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}