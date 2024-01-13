import 'package:flutter/material.dart';
import 'interface/drive_launcher.dart';

void main() {
  runApp(const SEDManagerApp());
}

class SEDManagerApp extends StatelessWidget {
  const SEDManagerApp({super.key});

  ThemeData _getTheme() {
    const colorScheme = ColorScheme(
      background: Color.fromARGB(255, 24, 24, 24),
      brightness: Brightness.dark,
      error: Color.fromARGB(255, 96, 22, 22),
      errorContainer: Color.fromARGB(255, 59, 13, 13),
      inversePrimary: Color.fromARGB(255, 220, 220, 220),
      inverseSurface: Color.fromARGB(255, 36, 138, 255),
      onBackground: Color.fromARGB(255, 220, 220, 220),
      onError: Color.fromARGB(255, 220, 220, 220),
      onErrorContainer: Color.fromARGB(255, 220, 220, 220),
      onInverseSurface: Color.fromARGB(255, 200, 200, 200),
      onPrimary: Color.fromARGB(255, 240, 240, 240),
      onPrimaryContainer: Color.fromARGB(255, 240, 240, 240),
      onSecondary: Color.fromARGB(255, 240, 240, 240),
      onSecondaryContainer: Color.fromARGB(255, 220, 220, 220),
      onSurface: Color.fromARGB(255, 220, 220, 220),
      onSurfaceVariant: Color.fromARGB(255, 220, 220, 220),
      onTertiary: Color.fromARGB(255, 220, 220, 220),
      onTertiaryContainer: Color.fromARGB(255, 220, 220, 220),
      outline: Color.fromARGB(255, 25, 145, 45),
      outlineVariant: Color.fromARGB(255, 9, 85, 22),
      primary: Color.fromARGB(255, 25, 145, 45),
      primaryContainer: Color.fromARGB(255, 38, 74, 44),
      scrim: Color.fromARGB(255, 25, 145, 45),
      secondary: Color.fromARGB(255, 9, 85, 22),
      secondaryContainer: Color.fromARGB(255, 35, 66, 40),
      shadow: Color.fromARGB(255, 0, 32, 0),
      surface: Color.fromARGB(255, 48, 50, 52),
      surfaceTint: Color.fromARGB(255, 19, 117, 182),
      surfaceVariant: Color.fromARGB(255, 45, 73, 50),
      tertiary: Color.fromARGB(255, 22, 61, 29),
      tertiaryContainer: Color.fromARGB(255, 22, 61, 29),
    );

    return ThemeData(
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SEDManager',
      theme: _getTheme(),
      home: DriveLauncherPage(() {}),
    );
  }
}
