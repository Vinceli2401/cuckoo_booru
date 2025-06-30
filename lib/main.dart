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
      child: MaterialApp(
        title: 'CuckooBooru',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
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
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
