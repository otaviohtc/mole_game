import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'menu.dart';
import 'game_state.dart';

void main() {
  runApp(
    // Wrap the app in the Provider
    ChangeNotifierProvider(
      create: (context) => GameState(),
      child: const MoleGameApp(),
    ),
  );
}

class MoleGameApp extends StatelessWidget {
  const MoleGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whac-A-Mole',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        scaffoldBackgroundColor: Colors.green[800],
      ),
      home: const MainMenu(),
    );
  }
}