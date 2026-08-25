// Platforma göre dosya-byte okuma. Web'de stub (null), diğerlerinde dart:io.
export 'file_bytes_stub.dart'
    if (dart.library.io) 'file_bytes_io.dart';
