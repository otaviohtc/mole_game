import 'package:flutter/material.dart';
import 'game.dart';
import 'shop.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[900], // Fundo rústico alinhado com a loja
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone decorativo acima do título
            Icon(Icons.pets, size: 60, color: Colors.orange[400]),
            const SizedBox(height: 16),

            // Título do Jogo
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
                    color: Colors.orange, // Leve brilho nas bordas das letras
                  ),
                ],
              ),
            ),
            const SizedBox(height: 70),
            
            // Botão de Jogar
            SizedBox(
              width: 240, // Tamanho fixo para deixar os botões alinhados
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: Colors.green[600], // Verde chamativo para ação principal
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.green[400]!, width: 3), // Borda brilhante
                  ),
                ),
                onPressed: () {
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

            // Botão da Loja
            SizedBox(
              width: 240,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: Colors.brown[700], // Cor de fundo dos itens da loja
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.orange[400]!, width: 3), // Borda laranja padrão
                  ),
                ),
                onPressed: () {
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