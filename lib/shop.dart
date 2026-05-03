import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_state.dart';
import 'game.dart';
import 'audio_utils.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[900],
      appBar: AppBar(
        title: const Text(
          'LOJA DE MELHORIAS', 
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            shadows: [
              Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
            ],
          )
        ),
        backgroundColor: Colors.transparent, // Fundo transparente para mesclar com o Scaffold
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.orange[400]),
        actions: [
          // Exibe as moedas atuais num "badge" igual ao do HUD do jogo
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Consumer<GameState>(
                builder: (context, gameState, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.orange[400]!, width: 2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '${gameState.coins}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: gameState.upgrades.length,
            itemBuilder: (context, index) {
              final upgrade = gameState.upgrades[index];
              
              final isMaxLevel = upgrade.level >= upgrade.maxLevel;
              final canAfford = gameState.coins >= upgrade.cost && !isMaxLevel;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.brown[700],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange[400]!, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.brown[800],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.brown[600]!, width: 2),
                        ),
                        child: Icon(upgrade.icon, size: 36, color: Colors.orange[400]),
                      ),
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${upgrade.name} (Nív ${upgrade.level})',
                              style: const TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.white
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              upgrade.description,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          backgroundColor: canAfford ? Colors.green[600] : Colors.brown[800],
                          foregroundColor: canAfford ? Colors.white : Colors.white38,
                          elevation: canAfford ? 5 : 0, // Tira a sombra se não puder comprar
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: canAfford ? Colors.green[400]! : Colors.brown[600]!,
                              width: 2,
                            ),
                          ),
                        ),
                        onPressed: canAfford
                            ? () {
                                AudioUtils.playBuy();
                                gameState.buyUpgrade(upgrade.id);
                              }
                            : null, // Desativa se não houver moedas ou estiver no nível máximo
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isMaxLevel ? Icons.check : Icons.monetization_on, 
                              size: 18, 
                              color: canAfford ? Colors.amber : Colors.white38
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isMaxLevel ? 'MÁXIMO' : '${upgrade.cost}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green[600],
        onPressed: () {
          AudioUtils.playTap();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GameScreen()),
          );
        },
        label: const Text(
          'JOGAR', 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)
        ),
        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white24, width: 2),
        ),
      ),
    );
  }
}