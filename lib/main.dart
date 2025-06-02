import 'package:flutter/material.dart';
import 'package:gymbroo/pages/SplashScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GYMBROO',
      theme: ThemeData(
        fontFamily: 'League Spartan', 
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'Konkhmer Sleokchher', 
            fontSize: 32,
            fontWeight: FontWeight.normal,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Konkhmer Sleokchher',
            fontSize: 28,
            fontWeight: FontWeight.normal,
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      home: const SplashScreen(),
      
    );
  }
}
