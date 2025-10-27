import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/app/providers/providers.dart';
import 'package:socialmedia/app/routes/app_route.dart';
import 'package:socialmedia/firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("🔔 Background Message: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _token = "";

  @override
  void initState() {
    super.initState();
    requestPermission();
    initFCM();
  }

  // 🔐 Request Notification Permission
  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('🟡 User granted provisional permission');
    } else {
      debugPrint('❌ User denied permission');
    }
  }

  // 🚀 Initialize Firebase Messaging Listeners
  void initFCM() async {
    // Register for Remote Notifications (IMPORTANT FOR iOS)
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    // Wait for APNS token (iOS only)
    String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    debugPrint("📢 APNS Token: $apnsToken");

    try {
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        debugPrint('New FCM Token: $newToken');
      });
      // Now safely get the FCM token
      FirebaseMessaging.instance.getToken().then((token) {
        if (token != null) {
          debugPrint("✅ FCM Token: $token");
          _token = token;
        } else {
          debugPrint("⏳ Waiting for FCM Token...");
        }
      });
    } catch (e) {
      debugPrint("error FCM Token $e");
    }

    // Foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 Foreground Message Received!');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
    });

    // When the app is opened from a terminated state via a notification
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        debugPrint('🚀 App opened from Terminated State via Notification');
      }
    });

    // When the app is in background and opened via notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📲 Notification Clicked');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: providers, child: Core());
  }
}

class Core extends StatelessWidget {
  const Core({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Media',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splashRoute,
      routes: AppRoutes.routes,
    );
  }
}
