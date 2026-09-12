import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import '../widgets/book_card.dart';
import '../main.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  String selectedCategory = 'All';
  late Future<List<Book>> _booksFuture;
  
  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  void _loadBooks() {
    _booksFuture = ApiService.fetchAllBooks();
  }
  
  List<Book> get allBooks => ApiService.allBooks;
  
  List<String> get categories {
    final cats = allBooks
        .map((b) => b.category?.name)
        .where((name) => name != null)
        .cast<String>()
        .toSet()
        .toList();
    cats.sort();
    return ['All', 'Smart Recommendation', ...cats];
  }

  List<Book> get filteredBooks {
    if (selectedCategory == 'All') return allBooks;
    
    if (selectedCategory == 'Smart Recommendation') {
      return ApiService.getSmartRecommendations();
    }
    
    return allBooks.where((b) => b.category?.name == selectedCategory).toList();
  }

  String tr(String key) => AppTexts.translate(key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppSettings.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(tr('books'), style: TextStyle(color: isDark ? const Color(0xFFD4AF37) : Colors.black)),
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: isDark ? Colors.white : Colors.black),
            onPressed: () => setState(() => _loadBooks()),
          )
        ],
      ),
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && allBooks.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
          }

          if (snapshot.hasError && allBooks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text('Failed to load books', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                  ElevatedButton(
                    onPressed: () => setState(() => _loadBooks()),
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = selectedCategory == cat;
                    
                    String displayTitle = cat;
                    if (cat == 'All') displayTitle = tr('all');
                    if (cat == 'Smart Recommendation') displayTitle = tr('smart_recommendation');

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(displayTitle),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = cat;
                          });
                        },
                        selectedColor: const Color(0xFFD4AF37),
                        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[200],
                        labelStyle: TextStyle(
                          color: isSelected 
                            ? Colors.black 
                            : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    );
                  },
                ),
              ),
              
              Expanded(
                child: filteredBooks.isEmpty
                    ? Center(child: Text(tr('no_books'), style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredBooks.length,
                        itemBuilder: (context, index) {
                          final book = filteredBooks[index];
                          return BookCard(book: book);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
