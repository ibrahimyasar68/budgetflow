import 'package:flutter/material.dart';

/// Etiket rozetleri ve gider dağılımı için ortak renk paleti.
const List<Color> kLabelPalette = [
  Color(0xFF6C5CE7),
  Color(0xFF2BC48A),
  Color(0xFFFF7043),
  Color(0xFF42A5F5),
  Color(0xFFAB47BC),
  Color(0xFFFFB300),
  Color(0xFFEC407A),
  Color(0xFF26A69A),
];

/// Nota göre tutarlı bir renk üretir (aynı etiket → her yerde aynı renk).
Color labelColor(String label) {
  final key = label.trim().toLowerCase();
  var hash = 0;
  for (final code in key.codeUnits) {
    hash = (hash * 31 + code) & 0x7fffffff;
  }
  return kLabelPalette[hash % kLabelPalette.length];
}
