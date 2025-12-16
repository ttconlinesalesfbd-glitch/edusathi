// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:student_app/dashboard/dashboard_screen.dart';
// import 'package:student_app/splash_screen.dart';
// import 'package:student_app/teacher/teacher_dashboard_screen.dart';
// import 'firebase_options.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// /// Background notification handler
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
// }

// /// Main function
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   // Register background handler
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   // 🔥 iOS Notification Permissions
//   await FirebaseMessaging.instance.requestPermission(
//     alert: true,
//     badge: true,
//     sound: true,
//   );

//   // 🔥 Display notifications when app is in foreground (iOS)
//   FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );

//   // Debug: Fetch FCM token
//   String? token = await FirebaseMessaging.instance.getToken();
//   print("FCM Token: $token");

//   // Shared Preferences handling
//   final prefs = await SharedPreferences.getInstance();
//   final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//   final userType = prefs.getString('user_type') ?? '';

//   Widget initialScreen;

//   if (isLoggedIn) {
//     if (userType == 'Teacher') {
//       initialScreen = TeacherDashboardScreen();
//     } else if (userType == 'Student') {
//       initialScreen = DashboardScreen();
//     } else {
//       initialScreen = SplashScreen();
//     }
//   } else {
//     initialScreen = SplashScreen();
//   }

//   runApp(MyApp(initialScreen: initialScreen));
// }

// class MyApp extends StatelessWidget {
//   final Widget initialScreen;
//   const MyApp({super.key, required this.initialScreen});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       debugShowCheckedModeBanner: false,
//       home: initialScreen,
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'package:student_app/splash_screen.dart';
import 'package:student_app/dashboard/dashboard_screen.dart';
import 'package:student_app/teacher/teacher_dashboard_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 🔔 Background notification handler (REQUIRED)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ ONLY Firebase init here (safe for iOS)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background handler
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
      home: const RootDecider(), // 🔥 LOGIC MOVED HERE
    );
  }
}

/// 🔥 THIS REPLACES YOUR OLD `main()` LOGIC SAFELY
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

    // Delay ensures first frame renders (CRITICAL for iOS)
    Future.delayed(const Duration(milliseconds: 300), _initApp);
  }

  Future<void> _initApp() async {
    try {
      // 🔔 Notification permissions
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Debug token (safe here)
      await FirebaseMessaging.instance.getToken();

      // 🔐 SharedPreferences logic (OLD CODE MOVED)
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
      // ❗ NEVER crash app on iOS
      _screen = const SplashScreen();
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return _screen;
  }
}

