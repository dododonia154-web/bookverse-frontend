import 'package:flutter/material.dart';
import '../models/book.dart';
import '../screens/book_details_screen.dart';
// import '../main.dart';

class BookCard extends StatefulWidget {
  final Book book;
  final VoidCallback? onTap; // إضافة callback للتحديث عند العودة
  const BookCard({super.key, required this.book, this.onTap});

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  @override
  Widget build(BuildContext context) {
    final bool isDark = AppSettings.isDarkMode;
    bool isLoved = BookState.isFavorite(widget.book.id);
    double? userRating = BookState.getUserRating(widget.book.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookDetailsScreen(book: widget.book),
        ),
      ).then((_) {
        if (mounted) {
          setState(() {});
          if (widget.onTap != null) {
            widget.onTap!(); // استدعاء الـ callback إذا كان موجوداً
          }
        }
      }),
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.book.imageUrl,
                    height: 170, 
                    width: 130, 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 170,
                      width: 130,
                      color: Colors.grey,
                      child: const Icon(Icons.book, size: 40),
                    ),
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        BookState.toggleFavorite(widget.book);
                      });
                      if (widget.onTap != null) {
                        widget.onTap!();
                      }
                    },
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: Icon(
                        Icons.favorite,
                        color: isLoved ? Colors.red : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 5,
                  left: 5,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFD4AF37), size: 12),
                            const SizedBox(width: 2),
                            Text(widget.book.rating.toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      if (userRating != null) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: Colors.black, size: 10),
                              const SizedBox(width: 2),
                              Text(userRating.toString(),
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(widget.book.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 14, 
                    color: isDark ? Colors.white : Colors.black)),
            Text(widget.book.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
