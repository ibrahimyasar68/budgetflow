import 'dart:io';

/// Mobil/masaüstünde dosya yolundan byte okur. FilePicker `withData` ile
/// byte döndürmediğinde (bazı Android içerik sağlayıcıları) yedek yol budur.
Future<List<int>?> readFileBytes(String? path) async {
  if (path == null) return null;
  final file = File(path);
  if (!await file.exists()) return null;
  return await file.readAsBytes();
}
