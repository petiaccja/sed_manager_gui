import 'package:flutter/material.dart';
import 'interface/drive_launcher.dart';

void main() {
  runApp(const SEDManagerApp());
}

class SEDManagerApp extends StatelessWidget {
  const SEDManagerApp({super.key});

  ColorScheme _getColorScheme() {
    const colorScheme = ColorScheme(
      background: Color.fromARGB(255, 32, 32, 32),
      brightness: Brightness.dark,
      error: Color.fromARGB(255, 96, 22, 22),
      onBackground: Color.fromARGB(255, 200, 200, 200),
      onError: Color.fromARGB(255, 220, 220, 220),
      onPrimary: Color.fromARGB(255, 220, 220, 220),
      onSecondary: Color.fromARGB(255, 220, 220, 220),
      onSurface: Color.fromARGB(255, 200, 200, 200),
      primary: Color.fromARGB(255, 38, 74, 44),
      secondary: Color.fromARGB(255, 35, 66, 40),
      surface: Color.fromARGB(255, 56, 57, 62),
      errorContainer: Color.fromARGB(255, 96, 48, 48),
      inversePrimary: Color.fromARGB(255, 220, 220, 220),
      inverseSurface: Color.fromARGB(255, 36, 138, 255),
      onErrorContainer: Color.fromARGB(255, 220, 220, 220),
      onInverseSurface: Color.fromARGB(255, 200, 200, 200),
      onPrimaryContainer: Color.fromARGB(255, 220, 220, 220),
      onSecondaryContainer: Color.fromARGB(255, 220, 220, 220),
      onSurfaceVariant: Color.fromARGB(255, 220, 220, 220),
      onTertiary: Color.fromARGB(255, 220, 220, 220),
      onTertiaryContainer: Color.fromARGB(255, 220, 220, 220),
      outline: Color.fromARGB(255, 87, 167, 100),
      outlineVariant: Color.fromARGB(255, 68, 131, 78),
      primaryContainer: Color.fromARGB(255, 38, 74, 44),
      scrim: Color.fromARGB(255, 87, 167, 100),
      secondaryContainer: Color.fromARGB(255, 35, 66, 40),
      shadow: Color.fromARGB(255, 0, 0, 0),
      surfaceTint: Color.fromARGB(255, 19, 117, 182),
      surfaceVariant: Color.fromARGB(255, 45, 73, 50),
      tertiary: Color.fromARGB(255, 35, 60, 40),
      tertiaryContainer: Color.fromARGB(255, 35, 60, 40),
    );
    return colorScheme;
    return ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 22, 42, 109),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SEDManager',
      theme: ThemeData(
        colorScheme: _getColorScheme(),
        useMaterial3: true,
      ),
      home: DriveLauncherPage(() {}),
    );
  }
}
