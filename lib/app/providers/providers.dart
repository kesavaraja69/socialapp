import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:socialmedia/core/notifiers/auth_provider.dart';
import 'package:socialmedia/core/notifiers/cache_provider.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => CacheNotifier()),
  ChangeNotifierProvider(create: (_) => AuthProvider()),
];
