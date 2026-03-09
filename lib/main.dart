import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/context_engine/presentation/context_settings_screen.dart';

void main() {
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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VANTAGE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_suggest),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ContextSettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'VANTAGE',
              style: GoogleFonts.montserrat(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Gestor de Vida Contextual',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            const Icon(Icons.explore_outlined, size: 60, color: Colors.deepPurpleAccent),
            const SizedBox(height: 20),
            const Text('Listo para configurar tu primer entorno.'),
          ],
        ),
      ),
    );
  }
}
