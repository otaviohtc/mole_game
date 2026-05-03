import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'menu.dart';
import 'game_state.dart';

void main() {
  runApp(
    // Envolve o app com o provider GameState para gerenciar o estado compartilhado entre as telas
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
      title: 'Bata na Toupeira',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        scaffoldBackgroundColor: Colors.green[800],
      ),
      home: const MainMenu(),
    );
  }
}