import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import '../widgets/book_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Book> _allBooks = ApiService.allBooks;
  List<Book> _filteredBooks = [];
  List<String> _selectedCategories = [];

  // استخراج التصنيفات الفعلية من الكتب المتاحة
  List<String> get _dynamicCategories {
    final categories = _allBooks
        .map((book) => book.category?.name ?? 'General')
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  @override
  void initState() {
    super.initState();
    _filteredBooks = _allBooks;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBooks = _allBooks.where((book) {
        bool matchesQuery =
            book.title.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query);

        String bookCategory = book.category?.name ?? 'General';
        bool matchesCategory = _selectedCategories.isEmpty ||
            _selectedCategories.contains(bookCategory);

        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  void _showFilterDialog() {
    final availableCategories = _dynamicCategories;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true, // مهم جداً
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView( // ✅ الحل هنا
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter by Category',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (availableCategories.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'No categories available',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availableCategories.map((category) {
                          bool isSelected =
                              _selectedCategories.contains(category);
                          return FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedCategories.add(category);
                                } else {
                                  _selectedCategories.remove(category);
                                }
                              });
                              setModalState(() {});
                              _applyFilters();
                            },
                            selectedColor: const Color(0xFFD4AF37),
                            checkmarkColor: Colors.black,
                            labelStyle: TextStyle(
                              color:
                                  isSelected ? Colors.black : Colors.white,
                            ),
                            backgroundColor: Colors.white10,
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black,
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // مساحة أمان
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search title or author...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFFD4AF37)),
                  filled: true,
                  fillColor: Colors.white10,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                color: _selectedCategories.isNotEmpty
                    ? const Color(0xFFD4AF37)
                    : Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: _selectedCategories.isNotEmpty
                      ? Colors.black
                      : const Color(0xFFD4AF37),
                ),
                onPressed: _showFilterDialog,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_selectedCategories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _selectedCategories
                      .map(
                        (cat) => Padding(
                          padding:
                              const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            label: Text(cat,
                                style:
                                    const TextStyle(fontSize: 12)),
                            onDeleted: () {
                              setState(() {
                                _selectedCategories.remove(cat);
                                _applyFilters();
                              });
                            },
                            deleteIconColor: Colors.black,
                            backgroundColor:
                                const Color(0xFFD4AF37),
                            labelStyle:
                                const TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          Expanded(
            child: _filteredBooks.isEmpty
                ? const Center(
                    child: Text(
                      'No books found',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredBooks.length,
                    itemBuilder: (context, index) {
                      return BookCard(
                          book: _filteredBooks[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
