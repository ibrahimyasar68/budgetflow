/// Web derlemesi için yer tutucu: dosya yolundan okuma desteklenmez
/// (web'de FilePicker zaten byte döndürür).
Future<List<int>?> readFileBytes(String? path) async => null;
