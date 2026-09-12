import 'package:flutter/material.dart';
import 'login_screen.dart';

class MultiSplashScreen extends StatefulWidget {
  const MultiSplashScreen({super.key});

  @override
  State<MultiSplashScreen> createState() => _MultiSplashScreenState();
}

class _MultiSplashScreenState extends State<MultiSplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _splashData = [
    {
      'title': 'Welcome to Bookverse',
      'subtitle': 'Your gateway to a world of endless stories and knowledge.',
      'icon': 'auto_stories',
    },
    {
      'title': 'Discover & Read',
      'subtitle': 'Explore thousands of books and start your reading journey today.',
      'icon': 'library_books',
    },
    {
      'title': 'Smart Recommendations',
      'subtitle': 'Get personalized book suggestions tailored just for you.',
      'icon': 'psychology',
    },
  ];

  void _nextPage() {
    if (_currentPage < _splashData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _splashData.length,
            itemBuilder: (context, index) {
              return SplashContent(
                title: _splashData[index]['title']!,
                subtitle: _splashData[index]['subtitle']!,
                iconName: _splashData[index]['icon']!,
              );
            },
          ),
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _splashData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? const Color(0xFFD4AF37)
                            : Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPage == _splashData.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // تم تعديل هذا الجزء لإظهار زر Skip فقط في الشاشات قبل الأخيرة
                if (_currentPage < _splashData.length - 1)
                  TextButton(
                    onPressed: _navigateToLogin,
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                else
                  const SizedBox(height: 48), // مساحة بديلة للحفاظ على توازن التصميم في الشاشة الأخيرة
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SplashContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconName;

  const SplashContent({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconName,
  });

  IconData _getIcon(String name) {
    switch (name) {
      case 'auto_stories':
        return Icons.auto_stories;
      case 'library_books':
        return Icons.library_books;
      case 'psychology':
        return Icons.psychology;
      default:
        return Icons.book;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIcon(iconName),
            size: 120,
            color: const Color(0xFFD4AF37),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
