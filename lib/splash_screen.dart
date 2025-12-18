import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/dashboard/dashboard_screen.dart';
import 'package:student_app/login_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:student_app/notification/notification_service.dart';
import 'package:student_app/teacher/teacher_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _checkLoginStatus();
  }

  Future<void> _initializeNotifications() async {
    // 🔔 Request permission FIRST (important for iOS)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 🔔 Initialize local notifications
    NotificationService.initialize(context);

    // 🔔 Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📲 Foreground notification: ${message.notification?.title}");
      NotificationService.display(message);
    });
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userType = prefs.getString('user_type') ?? '';

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => userType == 'Teacher'
              ? const TeacherDashboardScreen()
              : const DashboardScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 120),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
