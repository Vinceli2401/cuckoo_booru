import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cuckoo_booru/ui/providers/app_state.dart';
import 'package:cuckoo_booru/ui/screens/search_screen.dart';
import 'package:cuckoo_booru/ui/screens/favorites_screen.dart';
import 'package:cuckoo_booru/ui/screens/collections_screen.dart';
import 'package:cuckoo_booru/ui/screens/about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SearchScreen(),
    const FavoritesScreen(),
    const CollectionsScreen(),
    const AboutScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load favorites when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Load favorites when switching to favorites tab
          if (index == 1) {
            context.read<AppState>().loadFavorites();
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_bookmark),
            label: 'Collections',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
        ],
        ),
      ),
    );
  }
}
