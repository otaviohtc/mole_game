import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'game_state.dart';
import 'shop.dart'; // Import the shop so we can navigate to it on Game Over

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // --- Game State (Local) ---
  int survivalSeconds = 0;
  int activeMoleIndex = -1;
  bool isGameOver = false;

  // --- Timers ---
  Timer? survivalTimer;
  Timer? moleSpawnerTimer;
  Timer? moleDespawnTimer;

  final Random random = Random();

  // --- Base Game Settings ---
  final int spawnRateMs = 2000; // How often a mole appears (2 seconds)
  final int baseMoleUptimeMs = 1500; // Base time before mole escapes (1.5 seconds)

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    setState(() {
      survivalSeconds = 0;
      activeMoleIndex = -1;
      isGameOver = false;
    });

    // 1. Start tracking survival time
    survivalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        survivalSeconds++;
      });
    });

    // 2. Start the mole spawner
    moleSpawnerTimer = Timer.periodic(Duration(milliseconds: spawnRateMs), (timer) {
      spawnMole();
    });
  }

  void spawnMole() {
    if (isGameOver) return;

    setState(() {
      activeMoleIndex = random.nextInt(9);
    });

    // --- APPLY UPGRADE: Time ---
    // Fetch the extra time from our GameState provider
    final gameState = Provider.of<GameState>(context, listen: false);
    final int currentMoleUptimeMs = baseMoleUptimeMs + gameState.extraMoleTimeMs;

    // 3. Start the despawn timer
    moleDespawnTimer?.cancel();
    moleDespawnTimer = Timer(Duration(milliseconds: currentMoleUptimeMs), () {
      if (activeMoleIndex != -1 && !isGameOver) {
        triggerGameOver();
      }
    });
  }

  void whack(int index) {
    if (isGameOver) return;

    if (index == activeMoleIndex) {
      moleDespawnTimer?.cancel(); // Stop the game over timer
      
      // --- APPLY UPGRADE: Multiplier ---
      // Fetch the coin multiplier and add coins to the global state
      final gameState = Provider.of<GameState>(context, listen: false);
      gameState.addCoins(gameState.coinMultiplier);

      setState(() {
        activeMoleIndex = -1; // Hide the mole
      });
    }
  }

  void triggerGameOver() {
    setState(() {
      isGameOver = true;
      activeMoleIndex = -1;
    });

    survivalTimer?.cancel();
    moleSpawnerTimer?.cancel();
    moleDespawnTimer?.cancel();

    showGameOverModal();
  }

  void showGameOverModal() {
    // Read the final coin count to display in the modal
    final currentCoins = Provider.of<GameState>(context, listen: false).coins;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Fail!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 30)),
          content: Text(
            'The mole got away!\n\nWallet: $currentCoins coins\nSurvived: $survivalSeconds seconds',
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Navigate to Shop and remove GameScreen from the stack 
                // so the back button goes to Main Menu
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const ShopScreen()),
                );
              },
              child: const Text('Go to Shop', style: TextStyle(fontSize: 18)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown[700], foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                startGame(); // Restart the game loop
              },
              child: const Text('Replay', style: TextStyle(fontSize: 18)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    survivalTimer?.cancel();
    moleSpawnerTimer?.cancel();
    moleDespawnTimer?.cancel();
    super.dispose();
  }

  String get formattedTime {
    int minutes = survivalSeconds ~/ 60;
    int seconds = survivalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[600],
        foregroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // --- CONNECT UI TO STATE ---
            // Consumer automatically rebuilds this text whenever coins change
            Consumer<GameState>(
              builder: (context, gameState, child) {
                return Text('Coins: ${gameState.coins}', style: const TextStyle(fontWeight: FontWeight.bold));
              },
            ),
            Text('Time: $formattedTime', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 9,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemBuilder: (context, index) {
                bool hasMole = index == activeMoleIndex;

                return GestureDetector(
                  onTap: () => whack(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.brown[900],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black54, width: 4),
                    ),
                    child: AnimatedScale(
                      scale: hasMole ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOutBack,
                      child: const Center(
                        child: Text(
                          '🐹',
                          style: TextStyle(fontSize: 60),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}