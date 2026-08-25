import 'package:flutter/material.dart';

/// Sayfalar arası ortak yumuşak geçiş (fade) rotası.
PageRouteBuilder<T> fadeRoute<T>(Widget page) => PageRouteBuilder<T>(
      pageBuilder: (_, a, __) => page,
      transitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (_, a, __, child) =>
          FadeTransition(opacity: a, child: child),
    );
