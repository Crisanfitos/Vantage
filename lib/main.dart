import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/api/auth_providers.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/dashboard/presentation/dashboard_view.dart';
import 'features/context_engine/presentation/context_banner_overlay.dart';
import 'features/context_engine/presentation/context_watcher_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: VantageApp()));
}

class VantageApp extends StatelessWidget {
  const VantageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vantage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    // Activa el vigilante de contexto
    ref.watch(contextWatcherProvider);

    return authState.when(
      data: (user) => user != null 
        ? const ContextBannerOverlay(child: VantageDashboard()) 
        : const LoginScreen(),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, trace) => Scaffold(body: Center(child: Text('Error de Auth: $e'))),
    );
  }
}
