import 'package:flutter/material.dart';
// import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'models/book.dart';
import 'services/notification_service.dart';

// --- نظام الترجمة البسيط (Localization System) ---
class AppTexts {
  static Map<String, Map<String, String>> _localizedValues = {
    'English': {
      'home': 'Home',
      'books': 'Books',
      'library': 'Library',
      'search': 'Search',
      'profile': 'Profile',
      'edit_profile': 'Edit Profile',
      'language': 'Language',
      'dark_mode': 'Dark Mode',
      'notifications': 'Notifications',
      'help_support': 'Help & Support',
      'logout': 'Logout',
      'save': 'Save',
      'saved': 'Saved',
      'cancel': 'Cancel',
      'name': 'Name',
      'password': 'Password',
      'no_books': 'No books found',
      'all': 'All',
      'smart_recommendation': 'Smart Recommendation',
      'rate_this_book': 'Rate this book',
      'your_rating': 'Your Rating',
      'rated_success': 'You rated this book',
      'by': 'by',
      'description': 'Description',
      'start_reading': 'Start Reading',
      'continue_reading': 'Continue Reading',
      'finished': 'Finished',
      'read': 'Read',
      'love': 'Love',
      'time_spent': 'Time spent reading',
    },
    'Arabic': {
      'home': 'الرئيسية',
      'books': 'الكتب',
      'library': 'المكتبة',
      'search': 'البحث',
      'profile': 'الملف الشخصي',
      'edit_profile': 'تعديل الملف الشخصي',
      'language': 'اللغة',
      'dark_mode': 'الوضع الليلي',
      'notifications': 'الإشعارات',
      'help_support': 'المساعدة والدعم',
      'logout': 'تسجيل الخروج',
      'save': 'حفظ',
      'saved': 'تم الحفظ',
      'cancel': 'إلغاء',
      'name': 'الاسم',
      'password': 'كلمة المرور',
      'no_books': 'لا توجد كتب',
      'all': 'الكل',
      'smart_recommendation': 'ترشيحات ذكية',
      'rate_this_book': 'قيم هذا الكتاب',
      'your_rating': 'تقييمك',
      'rated_success': 'لقد قمت بتقييم الكتاب بـ',
      'by': 'بواسطة',
      'description': 'الوصف',
      'start_reading': 'ابدأ القراءة',
      'continue_reading': 'متابعة القراءة',
      'finished': 'تم الانتهاء',
      'read': 'قراءة',
      'love': 'أعجبني',
      'time_spent': 'الوقت المقضي في القراءة',
    },
    'French': {
      'home': 'Accueil',
      'books': 'Livres',
      'library': 'Bibliothèque',
      'search': 'Recherche',
      'profile': 'Profil',
      'edit_profile': 'Modifier le profil',
      'language': 'Langue',
      'dark_mode': 'Mode sombre',
      'notifications': 'Notifications',
      'help_support': 'Aide et support',
      'logout': 'Se déconnecter',
      'save': 'Enregistrer',
      'saved': 'Enregistré',
      'cancel': 'Annuler',
      'name': 'Nom',
      'password': 'Mot de passe',
      'no_books': 'Aucun livre trouvé',
      'all': 'Tout',
      'smart_recommendation': 'Recommandation intelligente',
      'rate_this_book': 'Évaluer ce livre',
      'your_rating': 'Votre évaluation',
      'rated_success': 'Vous avez évalué ce livre',
      'by': 'par',
      'description': 'Description',
      'start_reading': 'Commencer la lecture',
      'continue_reading': 'Continuer la lecture',
      'finished': 'Terminé',
      'read': 'Lire',
      'love': 'J\'aime',
      'time_spent': 'Temps passé à lire',
    },
  };

  static String translate(String key) {
    String lang = AppSettings.language;
    return _localizedValues[lang]?[key] ?? key;
  }
}

class AppStateManager extends ChangeNotifier {
  static final AppStateManager _instance = AppStateManager._internal();
  factory AppStateManager() => _instance;
  AppStateManager._internal();

  bool get isDarkMode => AppSettings.isDarkMode;
  void toggleTheme() {
    AppSettings.toggleDarkMode();
    notifyListeners(); 
  }

  String get language => AppSettings.language;
  void changeLanguage(String lang) {
    AppSettings.setLanguage(lang);
    notifyListeners(); 
  }
  

  bool get notificationsEnabled => AppSettings.notificationsEnabled;
  void toggleNotifications() {
    AppSettings.toggleNotifications();
    notifyListeners();
  }

  // دمج نظام الإشعارات
  final NotificationService _notificationService = NotificationService();
  int get unreadNotificationsCount => _notificationService.notifications.where((n) => !n.isRead).length;

    Future<void> initializeNotifications() async {
    debugPrint("Initializing notifications system...");
    // إضافة await هنا ضرورية لأن الإعدادات أصبحت حقيقية وتستغرق وقتاً
    await _notificationService.init(); 
    
    _notificationService.notificationsStream.listen((_) {
      notifyListeners();
    });
  }

}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStateManager().initializeNotifications();
  runApp(const BookverseApp());
}

class BookverseApp extends StatefulWidget {
  const BookverseApp({super.key});

  @override
  State<BookverseApp> createState() => _BookverseAppState();
}

class _BookverseAppState extends State<BookverseApp> {
  @override
  void initState() {
    super.initState();
    AppStateManager().addListener(_updateState);
  }

  @override
  void dispose() {
    AppStateManager().removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateManager();
    
    return MaterialApp(
      key: ValueKey(state.language), 
      title: 'Bookverse',
      debugShowCheckedModeBanner: false,
      themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37),
          primary: const Color(0xFFD4AF37),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37),
          primary: const Color(0xFFD4AF37),
          brightness: Brightness.dark,
          surface: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.black,
      ),
      
      home: const MultiSplashScreen(),
    );
  }
}
