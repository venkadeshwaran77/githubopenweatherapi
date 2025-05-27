// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openweatherapi/provider/theme/theme.dart';
import 'package:openweatherapi/provider/theme_provider.dart';
import 'package:openweatherapi/screens/splash_screen.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    return MaterialApp(
      theme:lightTheme,
      darkTheme:darkTheme,
      themeMode:themeMode,
    debugShowCheckedModeBanner: false,
    home: SplashScreen()
    );
  }
}
