import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/context_engine/presentation/context_settings_screen.dart';

void main() async {
  // Asegura que los bindings de Flutter estén inicializados antes de Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa Firebase con las opciones generadas por FlutterFire CLI
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
              'Cloud Connected',
              style: TextStyle(
                fontSize: 16,
                color: Colors.cyanAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            const Icon(Icons.cloud_done_outlined, size: 60, color: Colors.cyanAccent),
            const SizedBox(height: 20),
            const Text('Listo para sincronizar tus entornos.'),
          ],
        ),
      ),
    );
  }
}
