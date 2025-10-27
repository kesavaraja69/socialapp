import 'package:flutter/material.dart';
import 'package:socialmedia/meta/screens/auth/login/login_screen.dart';
import 'package:socialmedia/meta/screens/auth/signup/signup_screen.dart';
import 'package:socialmedia/meta/screens/home/home_screen.dart';
import 'package:socialmedia/meta/screens/post/add_post_screen.dart';
import 'package:socialmedia/meta/screens/splash_screen.dart';

class AppRoutes {
  static const String loginRoute = "/login";
  static const String signupRoute = "/signup";
  static const String homeRoute = "/home";
  static const String uploadRoute = "/upload";
  static const String splashRoute = "/splash";

  static Map<String, Widget Function(BuildContext)> routes = {
    signupRoute: (context) => const SignupScreen(),
    loginRoute: (context) => const LoginScreen(),
    homeRoute: (context) => HomeScreen(),
    uploadRoute: (context) => CreatePostScreen(),
    splashRoute: (context) => SplashScreen(),
  };
}
