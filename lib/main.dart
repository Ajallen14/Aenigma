import 'package:flutter/material.dart';
import 'package:useless/splash_screen.dart';

void main() {
  runApp(const UnsolvablePuzzleApp());
}

class UnsolvablePuzzleApp extends StatelessWidget {
  const UnsolvablePuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Unsolvable Puzzle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
      ),
      home: const SplashScreen(),
    );
  }
}
