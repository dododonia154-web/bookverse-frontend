import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/book.dart';
import 'notification_service.dart';

class ApiService {
  static List<Book> allBooks = [];

  static String get baseUrl {
    if (kIsWeb ) {
      return 'http://127.0.0.1:8001/api';
    } else {
      return 'http://10.0.2.2:8001/api';
    }
  }

  static Map<String, String> get _headers {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (UserSession.token != null ) {
      headers['Authorization'] = 'Bearer ${UserSession.token}';
    }
    return headers;
  }

  static List<dynamic> _getDataList(dynamic body) {
    if (body is List) return body;
    if (body is Map) {
      if (body.containsKey('results')) return body['results'];
      if (body.containsKey('books')) return body['books'];
    }
    return [];
  }

  static Future<List<Book>> fetchAllBooks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/books/sections/allbooks/' ), headers: _headers);
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        List<dynamic> data = _getDataList(decodedData);
        allBooks = data.map((json) => Book.fromJson(json)).toList();
        for (var book in allBooks) {
          BookState.updateBook(book);
        }
        return allBooks;
      }
      throw Exception('Failed to load books: ${response.statusCode}');
    } catch (e) {
      print('Error fetching books: $e');
      rethrow;
    }
  }

  static Future<List<Book>> fetchBooksByCategory(int categoryId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/books/sections/pagecategory/$categoryId/' ), headers: _headers);
      if (response.statusCode == 200) {
        List<dynamic> data = _getDataList(json.decode(response.body));
        return data.map((json) => Book.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching books by category: $e');
      return [];
    }
  }

  static Future<List<Book>> fetchNewBooks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/books/sections/new/' ), headers: _headers);
      if (response.statusCode == 200) {
        List<dynamic> data = _getDataList(json.decode(response.body));
        return data.map((json) => Book.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching new books: $e');
      return [];
    }
  }

  static Future<Book?> fetchBookDetail(String bookId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/books/sections/book/$bookId/' ), headers: _headers);
      if (response.statusCode == 200) {
        final book = Book.fromJson(json.decode(response.body));
        BookState.updateBook(book);
        return book;
      }
      return null;
    } catch (e) {
      print('Error fetching book detail: $e');
      return null;
    }
  }

  static List<Book> getSmartRecommendations() {
    if (allBooks.isEmpty) return [];
    var sortedBooks = List<Book>.from(allBooks);
    sortedBooks.sort((a, b) => b.rating.compareTo(a.rating));
    var topBooks = sortedBooks.take(40).toList()..shuffle();
    return topBooks.take(6).toList();
  }

  static void simulateNewBookArrival() {
    NotificationService.showNotification(
      title: 'New Arrival! 📚',
      body: 'A new bestseller has just been added to Bookverse. Check it out!',
    );
  }

  static Future<Map<String, dynamic>> registerUser(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/register/' ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password
        }),
      );
      
      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        var errorData = json.decode(response.body);
        String errorMessage = 'Registration failed';
        if (errorData is Map) {
          if (errorData.containsKey('username')) {
            errorMessage = errorData['username'][0];
          } else if (errorData.containsKey('email')) {
            errorMessage = errorData['email'][0];
          } else if (errorData.containsKey('detail')) {
            errorMessage = errorData['detail'];
          }
        }
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('Registration error: $e');
      return {'success': false, 'message': 'Connection error. Please check your server.'};
    }
  }

  static Future<bool> loginUser(String emailOrUsername, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/login/' ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': emailOrUsername,
          'password': password
        }),
      );
      
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String name = data['username'] ?? emailOrUsername;
        String email = data['email'] ?? emailOrUsername;
        UserSession.login(email, name, authToken: data['access']);
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // --- OTP & Forgot Password Functions ---

  static Future<Map<String, dynamic>> sendForgotPasswordOTP(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/forgot-password/' ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );
      var data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'], 'otp_debug': data['otp_debug']};
      }
      return {'success': false, 'message': data['email']?[0] ?? 'Failed to send OTP'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  static Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/verify-otp/' ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'otp_code': otp}),
      );
      var data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }
      return {'success': false, 'message': data['error'] ?? 'Invalid OTP'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(String email, String otp, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/reset-password/' ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'otp_code': otp,
          'new_password': newPassword
        }),
      );
      var data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }
      return {'success': false, 'message': data['error'] ?? 'Failed to reset password'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  // --- Library Functions ---

  static Future<bool> toggleFavorite(int bookId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/library/' ),
        headers: _headers,
        body: json.encode({
          'book': bookId,
          'is_favorite': true,
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Book>> fetchUserLibrary() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/library/' ), headers: _headers);
      if (response.statusCode == 200) {
        List<dynamic> data = _getDataList(json.decode(response.body));
        return data.map((json) => Book.fromJson(json['book'])).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> updateLibraryStatus(String bookId, {String? status, bool? isFavorite}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/library/update-status/' ),
        headers: _headers,
        body: json.encode({
          'book': bookId,
          if (status != null) 'status': status,
          if (isFavorite != null) 'is_favorite': isFavorite,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating library status: $e');
      return false;
    }
  }

  static Future<List<Book>> fetchRecommendedBooks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/books/sections/recommended/' ), headers: _headers);
      if (response.statusCode == 200) {
        List<dynamic> data = _getDataList(json.decode(response.body));
        return data.map((json) => Book.fromJson(json)).toList();
      }
      return getSmartRecommendations();
    } catch (e) {
      print('Error fetching recommended books: $e');
      return getSmartRecommendations();
    }
  }
}
