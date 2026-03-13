import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/context_engine/presentation/context_banner_overlay.dart';

/// Provee el tema dinámico basado en el entorno activo
final dynamicThemeProvider = Provider<ThemeData>((ref) {
  final activeEnv = ref.watch(currentActiveEnvironmentProvider);
  
  // Color por defecto (Vantage Purple) si no hay entorno activo
  final Color seedColor = activeEnv != null 
      ? Color(activeEnv.colorSeedValue) 
      : const Color(0xFF673AB7);

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark, // Vantage es Dark Mode por defecto
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
});
