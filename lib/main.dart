import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/auth/session_controller.dart';
import 'core/di/providers.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Pre-cache brand fonts so the first frame uses Space Grotesk / Red Hat Display.
  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.spaceGrotesk(),
      GoogleFonts.redHatDisplay(),
    ]).timeout(const Duration(seconds: 3));
  } catch (_) {}
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const EventManagementApp(),
    ),
  );
}

class EventManagementApp extends ConsumerStatefulWidget {
  const EventManagementApp({super.key});

  @override
  ConsumerState<EventManagementApp> createState() => _EventManagementAppState();
}

class _EventManagementAppState extends ConsumerState<EventManagementApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionControllerProvider).bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(sessionControllerProvider.select((s) => s.status));

    return MaterialApp(
      // Reset the navigator when auth status changes so pushed routes
      // (e.g. Account) cannot outlive a sign-out.
      key: ValueKey(status),
      title: 'Ridivo Event Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: switch (status) {
        SessionStatus.unknown => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        SessionStatus.signedOut => const LoginScreen(),
        SessionStatus.signedIn => const HomeShell(),
      },
    );
  }
}
