import 'package:flutter/material.dart';
import 'package:secondary_screen/home_screen.dart';
import 'package:secondary_screen/promotion_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          case '/promotion':
            return MaterialPageRoute(builder: (context) => const PromotionScreen());
        }
        return null;
      },
    );
  }
}