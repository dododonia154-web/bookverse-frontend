import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'books_screen.dart'; // استيراد الشاشة الجديدة
import '../main.dart';
import '../models/book.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  
 
  final List<Widget> _screens = [
    const HomeScreen(), 
    const BooksScreen(), 
    const LibraryScreen(), 
    const SearchScreen(), 
    const ProfileScreen()
  ];

  String tr(String key) => AppTexts.translate(key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppSettings.isDarkMode;
    
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? Colors.black : Colors.white,
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: isDark ? Colors.white54 : Colors.black45,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: tr('home')),
          BottomNavigationBarItem(icon: const Icon(Icons.explore), label: tr('books')), 
          BottomNavigationBarItem(icon: const Icon(Icons.auto_stories), label: tr('library')),
          BottomNavigationBarItem(icon: const Icon(Icons.search), label: tr('search')),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: tr('profile')),
        ],
      ),
    );
  }
}
