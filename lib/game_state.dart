import 'package:flutter/material.dart';

// A simple model to represent an Upgrade
class Upgrade {
  final String id;
  final String name;
  final String description;
  final IconData icon; // Using an Icon as a placeholder for your future images
  int cost;
  int level; // How many times we bought it

  Upgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.cost,
    this.level = 0,
  });
}

class GameState extends ChangeNotifier {
  int _coins = 0;
  int get coins => _coins;

  // Our list of available upgrades
  final List<Upgrade> _upgrades = [
    Upgrade(
      id: 'multi',
      name: 'Golden Mallet',
      description: 'Earn +1 extra coin per whack.',
      icon: Icons.gavel,
      cost: 10,
    ),
    Upgrade(
      id: 'time',
      name: 'Slowpoke Moles',
      description: 'Moles stay out longer before disappearing.',
      icon: Icons.hourglass_bottom,
      cost: 20,
    ),
  ];

  List<Upgrade> get upgrades => _upgrades;

  // Called from game.dart when whacking a mole
  void addCoins(int amount) {
    _coins += amount;
    notifyListeners(); // Tells the UI to redraw
  }

  // Called from shop.dart when buying an upgrade
  bool buyUpgrade(String id) {
    final upgrade = _upgrades.firstWhere((u) => u.id == id);
    if (_coins >= upgrade.cost) {
      _coins -= upgrade.cost;
      upgrade.level++;
      upgrade.cost = (upgrade.cost * 1.5).round(); // Make it more expensive next time!
      notifyListeners();
      return true; // Success
    }
    return false; // Not enough coins
  }

  // Helper getters that our game.dart can use later to apply the upgrades!
  int get coinMultiplier => 1 + _upgrades.firstWhere((u) => u.id == 'multi').level;
  int get extraMoleTimeMs => _upgrades.firstWhere((u) => u.id == 'time').level * 500;
}