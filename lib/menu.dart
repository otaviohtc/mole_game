import 'package:flutter/material.dart';
import 'game.dart';
import 'shop.dart';
import 'audio_utils.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            const Text(
              'BATA NA\nTOUPEIRA',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 3,
                height: 1.1,
                shadows: [
                  Shadow(
                    offset: Offset(4.0, 4.0),
                    blurRadius: 6.0,
                    color: Colors.black87,
                  ),
                  Shadow(
                    offset: Offset(-1.0, -1.0),
                    blurRadius: 0.0,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 70),
            
            SizedBox(
              width: 240, // Largura fixa para alinhamento dos botões
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.green[400]!, width: 3),
                  ),
                ),
                onPressed: () {
                  AudioUtils.playTap();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 32),
                label: const Text(
                  'JOGAR',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: 240,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: Colors.brown[700],
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.orange[400]!, width: 3),
                  ),
                ),
                onPressed: () {
                  AudioUtils.playTap();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ShopScreen()),
                  );
                },
                icon: Icon(Icons.storefront_rounded, size: 32, color: Colors.orange[400]),
                label: const Text(
                  'LOJA',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}