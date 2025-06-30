import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cuckoo_booru/ui/screens/home_screen.dart';
import 'package:cuckoo_booru/ui/providers/app_state.dart';

void main() {
  runApp(const CuckooBooruApp());
}

class CuckooBooruApp extends StatelessWidget {
  const CuckooBooruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'CuckooBooru',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
