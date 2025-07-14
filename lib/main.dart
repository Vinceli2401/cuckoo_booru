import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cuckoo_booru/ui/screens/home_screen.dart';
import 'package:cuckoo_booru/ui/providers/app_state.dart';

void main() {
  runApp(const CuckooBooruApp());
}

class CuckooBooruApp extends StatelessWidget {
  const CuckooBooruApp({super.key});

  // Custom color scheme with deepslate black and neon blue
  static const Color deepslateBlack = Color(0xFF1E1E2E);
  static const Color neonBlue = Color(0xFF00D9FF);
  static const Color darkSlate = Color(0xFF2A2A3E);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'CuckooBooru',
            debugShowCheckedModeBanner: false,
            themeMode: appState.themeMode,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: neonBlue,
        secondary: neonBlue,
        surface: deepslateBlack,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        primaryContainer: darkSlate,
        onPrimaryContainer: neonBlue,
        onSecondaryContainer: Colors.white70,
      ),
      scaffoldBackgroundColor: deepslateBlack,
      cardColor: darkSlate,
      appBarTheme: AppBarTheme(
        backgroundColor: darkSlate,
        foregroundColor: neonBlue,
        elevation: 2,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSlate,
        selectedItemColor: neonBlue,
        unselectedItemColor: Colors.white60,
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF0066CC),
        secondary: const Color(0xFF0066CC),
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        primaryContainer: const Color(0xFFE3F2FD),
        onPrimaryContainer: const Color(0xFF0066CC),
        onSecondaryContainer: Colors.black87,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF0066CC),
        elevation: 2,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF0066CC),
        unselectedItemColor: Colors.black54,
      ),
    );
  }
}
