import 'package:flutter/material.dart';
import '../models/book.dart';
import '../widgets/book_card.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Library',
              style: TextStyle(color: Color(0xFFD4AF37))),
          backgroundColor: Colors.black,
          bottom: TabBar(
            indicatorColor: const Color(0xFFD4AF37),
            labelColor: const Color(0xFFD4AF37),
            unselectedLabelColor: Colors.white54,
            onTap: (index) {
              // تحديث الواجهة عند التنقل بين التبويبات لضمان ظهور أحدث البيانات
              setState(() {});
            },
            tabs: const [
              Tab(text: 'Reading'), // الكتب التي لم ينتهِ منها بعد
              Tab(text: 'Finished'), // الكتب التي انتهى من قراءتها
              Tab(text: 'Love & Save'), // المفضلة والمحفوظة كما هي
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookGrid(BookState.getCurrentlyReading(), 'No books being read yet'),
            _buildBookGrid(BookState.getFinishedBooks(), 'No books finished yet'),
            _buildLoveAndSaveTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookGrid(List<Book> books, String emptyMessage) {
    if (books.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return BookCard(
          book: books[index],
          onTap: () {
            // تحديث الواجهة عند العودة من صفحة تفاصيل الكتاب
            setState(() {});
          },
        );
      },
    );
  }

  Widget _buildLoveAndSaveTab() {
    final favoriteBooks = BookState.getFavoriteBooks();
    final savedBooks = BookState.getSavedBooks();

    // دمج القائمتين بدون تكرار
    final allItems = {...favoriteBooks, ...savedBooks}.toList();

    return _buildBookGrid(allItems, 'No loved or saved books yet');
  }
}
