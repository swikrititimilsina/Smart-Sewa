import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';

class SmartSewaApp extends StatelessWidget {
  const SmartSewaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Sewa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A5276)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}