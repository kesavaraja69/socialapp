import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/app/providers/providers.dart';
import 'package:socialmedia/app/routes/app_route.dart';
import 'package:socialmedia/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      initialRoute: AppRoutes.loginRoute,
      routes: AppRoutes.routes,

      // theme: ThemeData(
      //   fontFamily: GoogleFonts.poppins().fontFamily,
      // ),
    );
  }
}
