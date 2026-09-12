import 'package:flutter/material.dart';
import '../models/book.dart';
import 'login_screen.dart';
import '../main.dart'; 
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showEditProfileDialog() {
    final String currentName = UserSession.userName;
    final String? currentEmail = UserSession.userEmail;
    final String currentPassword =
        UserSession.registeredUsers[currentEmail]?.password ?? "";

    final TextEditingController nameController =
        TextEditingController(text: currentName);
    final TextEditingController passwordController =
        TextEditingController(text: currentPassword);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Edit Profile',
            style: TextStyle(color: Color(0xFFD4AF37))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Color(0xFFD4AF37)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Password (Optional)',
                labelStyle: TextStyle(color: Color(0xFFD4AF37)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Email: $currentEmail (Cannot be changed)',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  UserSession.updateProfile(
                    nameController.text,
                    passwordController.text.isNotEmpty ? passwordController.text : currentPassword,
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37)),
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Select Language', style: TextStyle(color: Color(0xFFD4AF37))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption('English'),
            _languageOption('Arabic'),
            _languageOption('French'),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(String lang) {
    return ListTile(
      title: Text(lang, style: const TextStyle(color: Colors.white)),
      trailing: AppSettings.language == lang 
          ? const Icon(Icons.check, color: Color(0xFFD4AF37)) 
          : null,
      onTap: () {
        AppStateManager().changeLanguage(lang);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Language changed to $lang')),
        );
      },
    );
  }

  void _showHelpSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Help & Support', style: TextStyle(color: Color(0xFFD4AF37))),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How can we help you?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Email: elfeky.omar.123@gmail.com', style: TextStyle(color: Colors.white70)),
            Text('Phone: +201150713792', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 10),
            Text('FAQ: Visit our website for more info.', style: TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // استخدام UserSession.userName للحصول على اسم المستخدم الصحيح
    final String userName = UserSession.userName;
    final String userEmail = UserSession.userEmail ?? "No email provided";

    return Scaffold(
      backgroundColor: AppSettings.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: AppSettings.isDarkMode ? const Color(0xFFD4AF37) : Colors.black)),
        backgroundColor: AppSettings.isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppSettings.isDarkMode ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFFD4AF37),
              child: Icon(Icons.person, size: 60, color: AppSettings.isDarkMode ? Colors.black : Colors.white),
            ),
            const SizedBox(height: 16),
            // عرض اسم المستخدم في نص الشاشة كما طلبت
            Text(
              userName,
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: AppSettings.isDarkMode ? Colors.white : Colors.black
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // عرض البريد الإلكتروني تحت الاسم بخط أصغر
            Text(
              userEmail, 
              style: TextStyle(
                color: AppSettings.isDarkMode ? Colors.white54 : Colors.black54, 
                fontSize: 16
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            _profileOption(Icons.edit, 'Edit Profile', onTap: _showEditProfileDialog),
            
            _profileOption(
              Icons.language, 
              'Language (${AppSettings.language})', 
              onTap: _showLanguageDialog
            ),
            
            _profileSwitchOption(
              Icons.dark_mode, 
              'Dark Mode', 
              AppSettings.isDarkMode, 
              (val) {
                AppStateManager().toggleTheme();
              }
            ),
            
            _profileSwitchOption(
              Icons.notifications, 
              'Notifications', 
              AppSettings.notificationsEnabled, 
              (val) {
                AppStateManager().toggleNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(val ? 'Notifications Enabled' : 'Notifications Disabled')),
                );
              }
            ),
            
            _profileOption(Icons.help_outline, 'Help & Support', onTap: _showHelpSupportDialog),

            _profileOption(Icons.new_releases, 'Simulate New Book ', onTap: () {
              ApiService.simulateNewBookArrival();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New book notification simulated!')),
              );
            }),
            
            _profileOption(Icons.logout, 'Logout', isLogout: true, onTap: () {
              UserSession.logout(); 
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (c) => const LoginScreen()),
                (route) => false,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _profileOption(IconData icon, String title, {bool isLogout = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : const Color(0xFFD4AF37)),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.red : (AppSettings.isDarkMode ? Colors.white : Colors.black))),
      trailing: Icon(Icons.chevron_right, color: AppSettings.isDarkMode ? Colors.white54 : Colors.black54),
      onTap: onTap,
    );
  }

  Widget _profileSwitchOption(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFD4AF37)),
      title: Text(title, style: TextStyle(color: AppSettings.isDarkMode ? Colors.white : Colors.black)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFD4AF37),
      ),
    );
  }
}
