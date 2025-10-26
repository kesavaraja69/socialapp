import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheNotifier extends ChangeNotifier {
  Future readCache({required String key}) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    var cacheData = sharedPreferences.getString(key);
    return cacheData;
  }

  Future writeCache({required String key, required String value}) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    await sharedPreferences.setString(key, value);
  }

  Future removeCache({required String key}) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    await sharedPreferences.remove(key);
  }
}
