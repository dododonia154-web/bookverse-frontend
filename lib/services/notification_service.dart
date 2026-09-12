import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/book.dart';
// import 'api_service.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });
}

class NotificationService {
  // ================== Singleton ==================
  static final NotificationService _instance =
      NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final List<NotificationModel> _notifications = [];
  final StreamController<List<NotificationModel>> _notificationController =
      StreamController<List<NotificationModel>>.broadcast();

  Stream<List<NotificationModel>> get notificationsStream =>
      _notificationController.stream;

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  // ================== INIT ==================
  Future<void> init() async {
    // في الويب، لا نقوم بتهيئة مكتبة الإشعارات المحلية لأنها غير مدعومة بنفس الطريقة
    if (kIsWeb) {
      debugPrint("Notifications: Web platform detected, skipping local notifications init.");
      return;
    }

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      // فحص دوري كل 15 دقيقة
      Timer.periodic(const Duration(minutes: 15), (_) {
        _checkUnfinishedBooks();
      });

      _checkUnfinishedBooks();
    } catch (e) {
      debugPrint("Error initializing notifications: $e");
    }
  }

  // ================== PUBLIC METHOD ==================
  static void showNotification({
    required String title,
    required String body,
  }) {
    NotificationService()._showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
    );
  }

  // ================== LOCAL NOTIFICATION ==================
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!AppSettings.notificationsEnabled) return;

    // إضافة الإشعار للقائمة الداخلية دائماً (تعمل في الويب والموبايل)
    _addNotificationToInternalList(title: title, body: body);

    // في الويب، نكتفي بالإضافة للقائمة الداخلية ولا نظهر إشعار النظام
    if (kIsWeb) return;

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'bookverse_channel_id',
        'Bookverse Notifications',
        channelDescription:
            'Notifications for new books and reading reminders',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _localNotifications.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint("Error showing notification: $e");
    }
  }

  // ================== BUSINESS LOGIC ==================
  void _checkUnfinishedBooks() {
    if (kIsWeb) return; // تخطي الفحص التلقائي في الويب
    
    final unfinishedBooks = BookState.getCurrentlyReading();
    for (var book in unfinishedBooks) {
      _showLocalNotification(
        id: book.id.hashCode,
        title: 'متابعة القراءة 📖',
        body:
            'لا تنسَ إكمال قراءة "${book.title}". لقد قطعت شوطاً رائعاً!',
        payload: 'book_id_${book.id}',
      );
    }
  }

  void notifyNewBook(Book book) {
    _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'كتاب جديد متاح! ✨',
      body:
          'تمت إضافة "${book.title}" بواسطة ${book.author} إلى المكتبة.',
      payload: 'new_book_${book.id}',
    );
  }

  void notifyBookFinished(Book book) {
    _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'تهانينا! 🎉',
      body: 'لقد أتممت قراءة "${book.title}". عمل رائع!',
      payload: 'finished_${book.id}',
    );
  }

  // ================== INTERNAL NOTIFICATIONS ==================
  void _addNotificationToInternalList({
    required String title,
    required String body,
  }) {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
    );

    _notifications.insert(0, notification);
    _notificationController.add(_notifications);
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      _notificationController.add(_notifications);
    }
  }

  void clearAll() {
    _notifications.clear();
    _notificationController.add(_notifications);
  }
}
