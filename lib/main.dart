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
import 'firebase_options.dart';
import 'package:student_app/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ ONLY Firebase init (safe)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ❌ NO notifications
  // ❌ NO SharedPreferences
  // ❌ NO login logic

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // ✅ ONLY FIRST PAGE
    );
  }
}
