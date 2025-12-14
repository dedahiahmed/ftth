import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const _uuid = Uuid();

  /// Upload a file to a specified bucket
  /// Returns the public URL of the uploaded file
  static Future<String?> uploadFile({
    required String bucketName,
    required File file,
    String? folder,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique filename with UUID
      final fileExtension = file.path.split('.').last;
      final uniqueFileName = '${_uuid.v4()}.$fileExtension';

      // Build path: userId/folder/uniqueFileName or userId/uniqueFileName
      final filePath = folder != null
          ? '$userId/$folder/$uniqueFileName'
          : '$userId/$uniqueFileName';

      // Upload file
      await _supabase.storage.from(bucketName).upload(
            filePath,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage.from(bucketName).getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Storage upload error: $e');
      return null;
    }
  }

  /// Delete a file from a specified bucket
  static Future<bool> deleteFile({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      await _supabase.storage.from(bucketName).remove([filePath]);
      return true;
    } catch (e) {
      print('Storage delete error: $e');
      return false;
    }
  }

  /// Get signed URL for private files
  static Future<String?> getSignedUrl({
    required String bucketName,
    required String filePath,
    int expiresIn = 3600,
  }) async {
    try {
      final signedUrl = await _supabase.storage
          .from(bucketName)
          .createSignedUrl(filePath, expiresIn);
      return signedUrl;
    } catch (e) {
      print('Storage signed URL error: $e');
      return null;
    }
  }
}
