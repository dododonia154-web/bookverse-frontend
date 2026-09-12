import 'package:flutter/material.dart';
import '../models/book.dart';
import '../widgets/book_card.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String category;
  final List<Book> books;
  const CategoryDetailScreen({super.key, required this.category, required this.books});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category, style: const TextStyle(color: Color(0xFFD4AF37))), backgroundColor: Colors.black),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.6, crossAxisSpacing: 16, mainAxisSpacing: 16),
        itemCount: books.length,
        itemBuilder: (context, index) => BookCard(book: books[index]),
      ),
    );
  }
}
