import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_state.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50], // Lighter background for the shop
      appBar: AppBar(
        title: const Text('Upgrades Shop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange[600],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Display current coins in the app bar
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Consumer<GameState>(
                builder: (context, gameState, child) {
                  return Text(
                    'Coins: ${gameState.coins}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
              final canAfford = gameState.coins >= upgrade.cost;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Upgrade Image Placeholder
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(upgrade.icon, size: 36, color: Colors.orange[800]),
                      ),
                      const SizedBox(width: 16),
                      
                      // Upgrade Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${upgrade.name} (Lvl ${upgrade.level})',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              upgrade.description,
                              style: TextStyle(color: Colors.grey[700], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      
                      // Buy Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canAfford ? Colors.green : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: canAfford
                            ? () {
                                gameState.buyUpgrade(upgrade.id);
                              }
                            : null, // Disables button if not enough coins
                        child: Text('Cost: ${upgrade.cost}'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}