import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/auth_service.dart';
import 'core/providers/app_providers.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: PirsApp()));
}

/// Navenda sepanê.
class PirsApp extends ConsumerStatefulWidget {
  const PirsApp({super.key});

  @override
  ConsumerState<PirsApp> createState() => _PirsAppState();
}

class _PirsAppState extends ConsumerState<PirsApp> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Token varsa kullanıcıyı yükle
    final token = await AuthService.getStoredUser();
    if (token != null && mounted) {
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser != null && mounted) {
        ref.read(currentUserProvider.notifier).state = currentUser;
      }
    }

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  ThemeData _buildLightTheme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF7F4FD),
      cardTheme: base.cardTheme.copyWith(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        centerTitle: true,
        elevation: 0,
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      cardTheme: base.cardTheme.copyWith(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        centerTitle: true,
        elevation: 0,
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return MaterialApp(
        title: 'Pirs Kurmancî',
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Pirs Kurmancî',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: user.isGuest ? const LoginScreen() : const HomeScreen(),
    );
  }
}
