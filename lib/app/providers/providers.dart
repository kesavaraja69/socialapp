import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:socialmedia/core/notifiers/auth_provider.dart';
import 'package:socialmedia/core/notifiers/cache_provider.dart';
import 'package:socialmedia/core/notifiers/post_provider.dart';
import 'package:socialmedia/core/notifiers/video_provider.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => CacheNotifier()),
  ChangeNotifierProvider(create: (_) => AuthProvider()),
  ChangeNotifierProvider(create: (_) => PostProvider()),
  ChangeNotifierProvider(create: (_) => VideoProvider()),
];
