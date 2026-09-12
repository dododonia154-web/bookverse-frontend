import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

import '../models/book.dart';
import '../services/notification_service.dart';

class ReadingScreen extends StatefulWidget {
  final Book book;
  const ReadingScreen({super.key, required this.book});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  Timer? _timer;
  int _secondsRead = 0;
  bool _isLaunching = false;

  @override
  void initState() {
    super.initState();

    // تحديث حالة الكتاب إلى "جاري القراءة"
    BookState.setStatus(widget.book.id, 'reading');
    BookState.updateBook(widget.book);

    // بدء عداد وقت القراءة
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsRead++);
    });
  }

  @override
  void dispose() {
    // حفظ وقت القراءة قبل الخروج
    BookState.addReadingTime(widget.book.id, _secondsRead);
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _openBook() async {
    if (_isLaunching) return;

    String? finalPdfUrl;

    /// 1️⃣ URL جاهز من الـ backend
    if (widget.book.pdfFileUrl != null &&
        widget.book.pdfFileUrl!.trim().isNotEmpty) {
      finalPdfUrl = widget.book.pdfFileUrl;
    }
    /// 2️⃣ رابط خارجي مباشر
    else if (widget.book.pdfUrl != null &&
        widget.book.pdfUrl!.trim().isNotEmpty) {
      finalPdfUrl = widget.book.pdfUrl;
    }
    /// 3️⃣ بناء الرابط يدويًا من pdf_file
    else if (widget.book.pdfFile != null &&
        widget.book.pdfFile!.trim().isNotEmpty) {
      final host =
          kIsWeb ? 'http://127.0.0.1:8000' : 'http://10.0.2.2:8000';

      finalPdfUrl = widget.book.pdfFile!.startsWith('http' )
          ? widget.book.pdfFile
          : '$host${widget.book.pdfFile!.startsWith('/') ? '' : '/'}${widget.book.pdfFile}';
    }

    // ❌ لا يوجد PDF
    if (finalPdfUrl == null || finalPdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ملف PDF غير متوفر لهذا الكتاب'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final uri = Uri.tryParse(finalPdfUrl.trim());
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رابط الكتاب غير صالح')),
      );
      return;
    }

    setState(() => _isLaunching = true);

    try {
      final success = await launchUrl(
        uri,
        mode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );

      if (!success) {
        throw Exception('Launch failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر فتح الكتاب. تأكد من وجود تطبيق PDF.\n$e',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLaunching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.book.title,
          style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _formatTime(_secondsRead),
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.picture_as_pdf,
              size: 120,
              color: Color(0xFFD4AF37),
            ),
            const SizedBox(height: 25),
            Text(
              widget.book.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.book.author,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 40),
            _isLaunching
                ? const CircularProgressIndicator(color: Color(0xFFD4AF37))
                : ElevatedButton.icon(
                    onPressed: _openBook,
                    icon: const Icon(Icons.menu_book),
                    label: const Text(
                      'ابدأ القراءة',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 35, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            // تحديث حالة الكتاب إلى "تمت القراءة"
            BookState.setStatus(widget.book.id, 'read');
            BookState.updateBook(widget.book);
            NotificationService().notifyBookFinished(widget.book);

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 تم إنهاء قراءة الكتاب'),
                backgroundColor: Colors.green,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'تمت القراءة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
