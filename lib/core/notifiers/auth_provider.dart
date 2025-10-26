import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;

  User? get user => _user;
  String get userId => _user?.uid ?? "";
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<String> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = cred.user;

      await _firestore.collection('users').doc(_user!.uid).set({
        'userId': _user!.uid,
        'name': name,
        'email': email,
        'profilePic': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = cred.user;
      notifyListeners();
      return "success";
    }
    // on FirebaseAuthException catch (e) {
    //   if (e.code == 'user-not-found') {
    //     return "No user found for that email.";
    //   } else if (e.code == 'wrong-password') {
    //     return "Wrong password provided.";
    //   } else if (e.code == 'invalid-email') {
    //     return "Invalid email format.";
    //   } else {
    //     return "Authentication error: ${e.message}";
    //   }
    // }
    catch (e) {
      debugPrint("firebase login error : ${e.toString()}");
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}
