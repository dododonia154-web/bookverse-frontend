import 'dart:async';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../widgets/book_card.dart';
import '../services/api_service.dart';
import 'category_detail_screen.dart';
import 'book_details_screen.dart';
import 'notifications_screen.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9, initialPage: 1000);
  Timer? _timer;
  
  late Future<List<Book>> _newBooksFuture;
  late Future<List<Book>> _allBooksFuture;
  late Future<List<Book>> _recommendedBooksFuture;
  
  // تصنيفات مخصصة لجعل الهوم غنية
  final List<String> _categories = [
    "Fiction",
    "Science",
    "History",
    "Technology",
    "Business",
    "Self-Help",
    "Philosophy",
    "Mystery",
    "Biography",
    "Fantasy",
    "Psychology"
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _startAutoScroll();
  }

  void _loadData() {
    _newBooksFuture = ApiService.fetchNewBooks();
    _allBooksFuture = ApiService.fetchAllBooks();
    _recommendedBooksFuture = ApiService.fetchRecommendedBooks();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(duration: const Duration(milliseconds: 1000), curve: Curves.easeInOutCubic);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookverse', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => setState(() => _loadData()),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
              ),
              if (AppStateManager().unreadNotificationsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${AppStateManager().unreadNotificationsCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _loadData());
        },
        child: FutureBuilder<List<Book>>(
          future: _allBooksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && ApiService.allBooks.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
            }
            
            if (snapshot.hasError && ApiService.allBooks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    const Text('Failed to load home data', style: TextStyle(color: Colors.white)),
                    ElevatedButton(
                      onPressed: () => setState(() => _loadData()),
                      child: const Text('Retry'),
                    )
                  ],
                ),
              );
            }
            
            final allBooks = ApiService.allBooks;
            
            return ListView(
              children: [
                const SizedBox(height: 15),
                
                // 1. Featured Books (New Arrivals) - السلايدر العلوي
                FutureBuilder<List<Book>>(
                  future: _newBooksFuture,
                  builder: (context, snapshot) {
                    final featuredBooks = snapshot.data ?? [];
                    if (featuredBooks.isEmpty && allBooks.isNotEmpty) {
                      // إذا لم تتوفر كتب جديدة، استخدم أول 5 كتب من الكل
                      final fallbackBooks = allBooks.take(10).toList();
                      return _buildFeaturedSlider(fallbackBooks);
                    }
                    return _buildFeaturedSlider(featuredBooks);
                  },
                ),
                
                const SizedBox(height: 20),
                
                // 2. Explore All Books - قسم شامل
                if (allBooks.isNotEmpty)
                  _buildCategorySection(context, "Explore All Books", allBooks),
                
                // 3. Dynamic Categories - تصنيفات متعددة
                ..._categories.map((catName) {
                  final catBooks = allBooks.where((b) => 
                    b.category?.name.toLowerCase() == catName.toLowerCase() ||
                    b.description.toLowerCase().contains(catName.toLowerCase())
                  ).toList();
                  
                  if (catBooks.isEmpty) return const SizedBox.shrink();
                  return _buildCategorySection(context, catName, catBooks);
                }).toList(),

                // 4. Recommendation Section - قسم الترشيحات (دائماً في الأخير)
                if (allBooks.isNotEmpty)
                  _buildRecommendationSection(context, allBooks),
                
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturedSlider(List<Book> books) {
    if (books.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 250,
      child: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) {
          final book = books[index % books.length];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => BookDetailsScreen(book: book))),
            child: _buildFeaturedCard(book),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCard(Book book) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(book.imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
          onError: (exception, stackTrace) {},
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(book.author, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, String title, List<Book> books) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => CategoryDetailScreen(category: title, books: books))),
                child: const Text('See All', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 14)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: books.length,
            itemBuilder: (context, index) => BookCard(book: books[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationSection(BuildContext context, List<Book> allBooks) {
    return FutureBuilder<List<Book>>(
      future: _recommendedBooksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && ApiService.allBooks.isNotEmpty) {
           return const SizedBox.shrink();
        }

        final apiBooks = snapshot.data ?? [];
        // Behavior-based local recommendations
        final behaviorBooks = BookState.getRecommendedByBehavior();
        
        // Merge recommendations: Prioritize behavior-based if available
        List<Book> finalBooks = [];
        if (behaviorBooks.isNotEmpty) {
          finalBooks.addAll(behaviorBooks);
          // Fill the rest with API recommendations or random books if needed
          for (var b in apiBooks) {
            if (finalBooks.length >= 6) break;
            if (!finalBooks.any((fb) => fb.id == b.id)) finalBooks.add(b);
          }
        } else {
          finalBooks = apiBooks;
        }
        
        // Final fallback if still empty
        if (finalBooks.isEmpty) {
          finalBooks = (List<Book>.from(allBooks)..shuffle()).take(6).toList();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFFD4AF37)),
                  SizedBox(width: 8),
                  Text(
                    "Recommended for You",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: finalBooks.length > 6 ? 6 : finalBooks.length,
              itemBuilder: (context, index) => BookCard(book: finalBooks[index]),
            ),
          ],
        );
      },
    );
  }
}
