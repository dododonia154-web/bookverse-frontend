import '../services/api_service.dart';

class Category {
  final int id;
  final String name;
  final List<BookSimple> books;
  Category({required this.id, required this.name, required this.books});
  factory Category.fromJson(Map<String, dynamic> json) {
    var booksList = json['books'] as List? ?? [];
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'General',
      books: booksList.map((b) => BookSimple.fromJson(b)).toList(),
    );
  }
}

class BookSimple {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  BookSimple({required this.id, required this.title, required this.author, required this.imageUrl});
  factory BookSimple.fromJson(Map<String, dynamic> json) {
    String coverUrl = json['cover'] ?? '';
    
    if (coverUrl.isEmpty) {
      coverUrl = 'https://via.placeholder.com/150';
    } else if (!coverUrl.startsWith('http' )) {
      coverUrl = 'http://10.0.2.2:8000$coverUrl';
    }

    return BookSimple(
      id: json['id'].toString( ),
      title: json['title'] ?? 'No Title',
      author: json['author'] ?? 'Unknown',
      imageUrl: coverUrl,
    );
  }
}

class Book {
  final String id;
  final String title;
  final String author;
  final Category? category;
  final String imageUrl;
  final double rating;
  final String description;
  final double price;
  final int pages;
  final String createdAt;
  bool isFavorite;
  int readingTimeInSeconds;
  String status;
  double? userRating;
  
  // حقول الـ PDF
  final String? pdfUrl;        // الرابط الخارجي (URL)
  final String? pdfFile;       // مسار الملف المرفوع (Relative Path)
  final String? pdfFileUrl;    // الرابط الكامل للملف المرفوع (Absolute URL من الـ Serializer)

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.category,
    required this.imageUrl,
    required this.rating,
    required this.description,
    this.price = 0.0,
    this.pages = 0,
    this.createdAt = '',
    this.isFavorite = false,
    this.readingTimeInSeconds = 0,
    this.status = 'none',
    this.userRating,
    this.pdfUrl,
    this.pdfFile,
    this.pdfFileUrl,
  });

    factory Book.fromJson(Map<String, dynamic> json) {
    // 1. جلب الرابط وتنظيفه من أي مسافات
    String coverUrl = (json['cover'] ?? '').toString().trim();
    
    // 2. التحقق من الرابط
    if (coverUrl.isEmpty || coverUrl.toLowerCase().endsWith('.pdf')) {
      // لو فاضي حط صورة افتراضية
      coverUrl = 'https://via.placeholder.com/150';
    } else if (coverUrl.startsWith('http'  )) {
      // لو بيبدأ بـ http سيبه زي ما هو (ده اللي هيشغل لينكات أمازون  )
      coverUrl = coverUrl; 
    } else {
      // لو مش بيبدأ بـ http يبقى ده ملف مرفوع على السيرفر بتاعك
      coverUrl = 'http://10.0.2.2:8000$coverUrl';
    }

    Category? cat;
    if (json['category'] != null  ) {
      if (json['category'] is Map<String, dynamic>) {
        cat = Category.fromJson(json['category']);
      } else {
        cat = Category(id: int.tryParse(json['category'].toString()) ?? 0, name: 'General', books: []);
      }
    }

    String bookId = json['id'].toString();
    
    return Book(
      id: bookId,
      title: json['title'] ?? 'No Title',
      author: json['author'] ?? 'Unknown',
      category: cat,
      imageUrl: coverUrl, // الرابط النهائي المعالج
      rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      pages: json['pages'] ?? 0,
      createdAt: json['created_at'] ?? '',
      isFavorite: BookState.favorites[bookId] ?? false,
      status: BookState.bookStatuses[bookId] ?? 'none',
      pdfUrl: json['pdf_url'],
      pdfFile: json['pdf_file'],
      pdfFileUrl: json['pdf_file_url'],
    );
  }

}

class   BookState {
  static final Map<String, bool> favorites = {};
  static final Map<String, bool> saved = {};
  static final Map<String, double> userRatings = {};
  static final Map<String, String> bookStatuses = {}; // حفظ حالة الكتاب (reading, read, none)
  static final Map<String, Book> allBooks = {};

  static void updateBook(Book book) {
    // التأكد من عدم ضياع الحالة عند تحديث الكتاب من الـ API
    if (bookStatuses.containsKey(book.id)) {
      book.status = bookStatuses[book.id]!;
    }
    if (favorites.containsKey(book.id)) {
      book.isFavorite = favorites[book.id]!;
    }
    allBooks[book.id] = book;
  }

  static void toggleFavorite(Book book) {
    favorites[book.id] = !(favorites[book.id] ?? false);
    book.isFavorite = favorites[book.id]!;
    updateBook(book);
    // مزامنة مع السيرفر
    ApiService.updateLibraryStatus(book.id, isFavorite: book.isFavorite);
  }

  static bool isFavorite(String id) {
    return favorites[id] ?? false;
  }

  static void toggleSave(Book book) {
    saved[book.id] = !(saved[book.id] ?? false);
    updateBook(book);
  }

  static bool isSaved(String id) {
    return saved[id] ?? false;
  }

  static void setUserRating(String id, double rating) {
    userRatings[id] = rating;
    if (allBooks.containsKey(id)) {
      allBooks[id]!.userRating = rating;
    }
  }

  static double? getUserRating(String id) {
    return userRatings[id];
  }

  static List<Book> getFavoriteBooks() {
    return allBooks.values.where((book) => favorites[book.id] == true).toList();
  }

  static List<Book> getSavedBooks() {
    return allBooks.values.where((book) => saved[book.id] == true).toList();
  }

  static List<Book> getCurrentlyReading() {
    return allBooks.values.where((book) => bookStatuses[book.id] == 'reading').toList();
  }

  static List<Book> getFinishedBooks() {
    return allBooks.values.where((book) => bookStatuses[book.id] == 'read').toList();
  }

  static void addReadingTime(String id, int seconds) {
    if (allBooks.containsKey(id)) {
      allBooks[id]!.readingTimeInSeconds += seconds;
    }
  }

  static void setStatus(String id, String status) {
    bookStatuses[id] = status;
    if (allBooks.containsKey(id)) {
      allBooks[id]!.status = status;
    }
    // مزامنة مع السيرفر
    ApiService.updateLibraryStatus(id, status: status);
  }

  // New logic for behavior-based recommendations
  static List<Book> getRecommendedByBehavior() {
    List<Book> userInteractedBooks = allBooks.values.where((book) {
      bool isFav = favorites[book.id] ?? false;
      bool highRating = (userRatings[book.id] ?? 0) >= 4;
      bool readMoreThanMinute = book.readingTimeInSeconds >= 60;
      return isFav || highRating || readMoreThanMinute;
    }).toList();

    if (userInteractedBooks.isEmpty) return [];

    Set<String> targetCategories = userInteractedBooks
        .map((b) => b.category?.name ?? 'General')
        .toSet();

    List<Book> recommendations = allBooks.values.where((book) {
     
      bool alreadyInteracted = userInteractedBooks.any((ub) => ub.id == book.id);
      bool inTargetCategory = targetCategories.contains(book.category?.name ?? 'General');
      return !alreadyInteracted && inTargetCategory;
    }).toList();


    recommendations.shuffle();
    return recommendations.take(6).toList();
  }
}

class UserData {
  String name;
  String password;
  UserData(this.name, this.password);
}

class UserSession {
  static String? userEmail;
  static String? currentUserName;
  static String? token;
  static Map<String, UserData> registeredUsers = {};
  
  static void login(String email, String name, {String? authToken}) {
    userEmail = email;
    currentUserName = name;
    token = authToken;
    
    // تخزين البيانات في القائمة المحلية للمحاكاة
    registeredUsers[email] = UserData(name, "");
  }
  
  static void updateProfile(String name, String password) {
    currentUserName = name;
    if (userEmail != null) {
      registeredUsers[userEmail!] = UserData(name, password);
    }
  }
  
  static void logout() {
    userEmail = null;
    currentUserName = null;
    token = null;
  }
  
  static String get userName {
    if (currentUserName != null && currentUserName!.isNotEmpty && !currentUserName!.contains('@')) {
      return currentUserName!;
    }
    if (userEmail != null && registeredUsers.containsKey(userEmail)) {
      String storedName = registeredUsers[userEmail!]!.name;
      if (storedName.isNotEmpty && !storedName.contains('@')) {
        return storedName;
      }
    }
    return "User"; 
  }
  
  static bool get isLoggedIn => userEmail != null;
}

class AppSettings {
  static bool isDarkMode = true;
  static String language = 'English';
  static bool notificationsEnabled = true;
  static void toggleDarkMode() {
    isDarkMode = !isDarkMode;
  }
  static void setLanguage(String lang) {
    language = lang;
  }
  static void toggleNotifications() {
    notificationsEnabled = !notificationsEnabled;
  }
}
