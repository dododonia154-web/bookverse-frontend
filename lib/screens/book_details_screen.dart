import 'package:flutter/material.dart';
import '../models/book.dart';
import 'reading_screen.dart';
import '../main.dart';
import '../services/api_service.dart';

class BookDetailsScreen extends StatefulWidget {
  final Book book;
  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  late double _currentUserRating;
  late Future<Book?> _bookFuture;
  Book? _currentBookData;

  @override
  void initState() {
    super.initState();
    _currentUserRating = BookState.getUserRating(widget.book.id) ?? 0.0;
    _loadBookData();
  }

  void _loadBookData() {
    _bookFuture = ApiService.fetchBookDetail(widget.book.id);
  }

  String tr(String key) => AppTexts.translate(key);

  void _updateRating(double rating) {
    setState(() {
      _currentUserRating = rating;
    });
    BookState.setUserRating(widget.book.id, rating);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${tr('rated_success')} $rating'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppSettings.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: BookState.isFavorite(widget.book.id) ? Colors.red : (isDark ? Colors.white : Colors.black),
            ),
            onPressed: () {
              setState(() {
                BookState.toggleFavorite(_currentBookData ?? widget.book);
              });
            },
          )
        ],
      ),
      body: FutureBuilder<Book?>(
        future: _bookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _currentBookData == null) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                  ElevatedButton(
                    onPressed: () => setState(() => _loadBookData()),
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
          }

          _currentBookData = snapshot.data ?? widget.book;
          final displayBook = _currentBookData!;
          bool isLoved = BookState.isFavorite(displayBook.id);
          bool isSaved = BookState.isSaved(displayBook.id);
          
          // الحصول على الحالة المحدثة من BookState
          final currentStatus = BookState.bookStatuses[displayBook.id] ?? displayBook.status;
          final readingTime = BookState.allBooks[displayBook.id]?.readingTimeInSeconds ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      displayBook.imageUrl,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 300,
                        width: 200,
                        color: Colors.grey,
                        child: const Icon(Icons.book, size: 100),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  displayBook.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                Text(
                  '${tr('by')} ${displayBook.author}',
                  style: TextStyle(fontSize: 18, color: isDark ? Colors.white70 : Colors.black54),
                ),
                const SizedBox(height: 8),
                if (readingTime > 0)
                  Text(
                    '${tr('time_spent')}: ${readingTime ~/ 60}m ${readingTime % 60}s',
                    style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 16),
                
                Text(
                  tr('rate_this_book'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () => _updateRating(index + 1.0),
                      icon: Icon(
                        index < _currentUserRating ? Icons.star : Icons.star_border,
                        color: const Color(0xFFD4AF37),
                        size: 30,
                      ),
                    );
                  }),
                ),
                if (_currentUserRating > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 16),
                    child: Text(
                      '${tr('your_rating')}: $_currentUserRating',
                      style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w500),
                    ),
                  ),

                Row(
                  children: [
                    _actionButton(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      isSaved ? tr('saved') : tr('save'),
                      onPressed: () {
                        setState(() {
                          BookState.toggleSave(displayBook);
                        });
                      },
                      isActive: isSaved,
                    ),
                    const SizedBox(width: 12),
                    _actionButton(
                      currentStatus == 'read' ? Icons.check_circle : Icons.check_circle_outline, 
                      currentStatus == 'read' ? tr('finished') : tr('read'), 
                      onPressed: () {
                        setState(() {
                          if (currentStatus == 'read') {
                            BookState.setStatus(displayBook.id, 'none');
                          } else {
                            BookState.setStatus(displayBook.id, 'read');
                          }
                          BookState.updateBook(displayBook);
                        });
                      },
                      isActive: currentStatus == 'read',
                    ),
                    const SizedBox(width: 12),
                    _actionButton(
                      Icons.favorite,
                      tr('love'),
                      isRed: true,
                      isActive: isLoved,
                      onPressed: () {
                        setState(() {
                          BookState.toggleFavorite(displayBook);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  tr('description'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  displayBook.description,
                  style: TextStyle(fontSize: 16, height: 1.5, color: isDark ? Colors.white70 : Colors.black87),
                ),
                const SizedBox(height: 40),
                _authButton(
                  currentStatus == 'reading' ? tr('continue_reading') : tr('start_reading'), 
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => ReadingScreen(book: displayBook)),
                    ).then((_) => setState(() {})); 
                  }
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label, {
    bool isRed = false,
    bool isActive = false,
    required VoidCallback onPressed,
  }) {
    final bool isDark = AppSettings.isDarkMode;
    Color iconColor;
    if (isRed) {
      iconColor = isActive ? Colors.red : (isDark ? Colors.white : Colors.black);
    } else {
      iconColor = isActive ? const Color(0xFFD4AF37) : (isDark ? Colors.white : Colors.black);
    }

    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: iconColor),
        label: Text(
          label,
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 12),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isActive ? const Color(0xFFD4AF37) : (isDark ? Colors.white24 : Colors.black26),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _authButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
