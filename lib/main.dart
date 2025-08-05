import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const ProviderScope(child: OHAApp()));
}

class OHAApp extends StatelessWidget {
  const OHAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OHA',
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
