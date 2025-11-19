import 'dart:typed_data';

import 'package:plan_ex_app/core/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  Future<String> uploadBytesToBucket({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {
    AppLogger.logString("Supabase: upload -> $bucket / $path");
    final res = await client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType),
        );
    AppLogger.logString("Supabase upload response: $res");

    final signed = await client.storage.from(bucket).createSignedUrl(path, 60 * 60 * 24 * 365);
    AppLogger.logString("SignedUrl: $signed");
    return signed;
  }
}