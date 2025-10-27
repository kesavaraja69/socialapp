import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/app/routes/app_route.dart';
import 'package:socialmedia/core/notifiers/cache_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkUserLoggedIn();
  }

  Future<void> checkUserLoggedIn() async {
    final cacheNotifier = Provider.of<CacheNotifier>(context, listen: false);
    await cacheNotifier.checkLoginStatus();

    /// Delay for splash effect
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        if (cacheNotifier.isLoggedIn == 'true') {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.homeRoute, (route) => false);
        } else {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.loginRoute, (route) => false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Social Media",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
