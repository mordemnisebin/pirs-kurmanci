import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';

/// Destpêka zimanê sepandê.
enum AppLocale {
  kurmanci,
  turkish,
}

/// Tema modê (light/dark).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Zimanê sepandê.
final localeProvider = StateProvider<AppLocale>((ref) => AppLocale.kurmanci);

/// Mîhengên dawî yên bikarhêner.
final currentUserProvider = StateProvider<UserProfile>((ref) => UserProfile.guest());
