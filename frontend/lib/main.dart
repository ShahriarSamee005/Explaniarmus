import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ExplaniarmusApp());
}

class ExplaniarmusApp extends StatelessWidget {
  const ExplaniarmusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explaniarmus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}