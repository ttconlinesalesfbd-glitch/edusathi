import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'package:student_app/splash_screen.dart';
import 'package:student_app/dashboard/dashboard_screen.dart';
import 'package:student_app/teacher/teacher_dashboard_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 🔔 Background notification handler (safe, optional)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// ✅ ONLY Firebase init here (CRITICAL for iOS)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const RootDecider(),
    );
  }
}

/// 🔥 SAFE replacement of your old main() logic
class RootDecider extends StatefulWidget {
  const RootDecider({super.key});

  @override
  State<RootDecider> createState() => _RootDeciderState();
}

class _RootDeciderState extends State<RootDecider> {
  Widget _screen = const SplashScreen();

  @override
  void initState() {
    super.initState();

    /// Delay ensures first frame renders (iOS requirement)
    Future.delayed(const Duration(milliseconds: 300), _initApp);
  }

  Future<void> _initApp() async {
    try {
      /// 🔔 Token (SAFE here, not in main)
      await FirebaseMessaging.instance.getToken();

      /// 🔐 SharedPreferences (your old logic)
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final userType = prefs.getString('user_type') ?? '';

      if (isLoggedIn) {
        if (userType == 'Teacher') {
          _screen = const TeacherDashboardScreen();
        } else if (userType == 'Student') {
          _screen = const DashboardScreen();
        } else {
          _screen = const SplashScreen();
        }
      } else {
        _screen = const SplashScreen();
      }
    } catch (e) {
      /// ❗ Never crash app on iOS
      _screen = const SplashScreen();
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _screen;
  }
}
