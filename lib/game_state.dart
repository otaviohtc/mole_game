import 'package:flutter/material.dart';

class Upgrade {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  int cost;
  int level;
  final int maxLevel;
  final List<int>? customCosts; // Para custos fixos específicos (ex: 50, 100, 150)

  Upgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.cost,
    this.level = 0,
    this.maxLevel = 99,
    this.customCosts,
  });
}

class GameState extends ChangeNotifier {
  int coins = 0; 
  
  int extraMoleTimeMs = 0;
  int coinMultiplier = 1;

  late List<Upgrade> upgrades;

  GameState() {
    upgrades = [
      Upgrade(
        id: 'golden_mallet', 
        name: 'Martelo Dourado', 
        description: 'Aumenta as moedas recebidas por acerto.', 
        icon: Icons.gavel, 
        cost: 10,
        maxLevel: 10,
      ),
      Upgrade(
        id: 'time', 
        name: 'Reflexos Lentos', 
        description: 'Toupeira fica mais tempo na tela.', 
        icon: Icons.timer, 
        cost: 15,
        maxLevel: 10,
      ),
      Upgrade(
        id: 'pacifist',
        name: 'Pacifista',
        description: 'Chance de não perder se a toupeira escapar (+5%).',
        icon: Icons.favorite,
        cost: 30, // Preço inicial
        maxLevel: 10,
      ),
      Upgrade(
        id: 'multi_mole',
        name: 'Infestação',
        description: 'Dobra a quantidade de toupeiras simultâneas.',
        icon: Icons.people,
        cost: 40,
        maxLevel: 2,
        customCosts: [40, 80], // Tabela de preços
      ),
      Upgrade(
        id: 'golden_mole',
        name: 'Toupeiras Douradas',
        description: 'Chance da toupeira valer 3x mais moedas (+5%).',
        icon: Icons.star,
        cost: 50,
        maxLevel: 3,
        customCosts: [50, 100, 150],
      ),
      Upgrade(
        id: 'survivor',
        name: 'Sobrevivente',
        description: 'Sobreviva 1 min para dobrar os ganhos do round.',
        icon: Icons.shield,
        cost: 100,
        maxLevel: 1, // Compra única
      ),
    ];
  }

  // Getters da jogabilidade para efeitos de upgrade
  int get maxMoles {
    int level = _getLevel('multi_mole');
    if (level == 1) return 2;
    if (level == 2) return 4;
    return 1; // Padrão
  }

  double get pacifistChance => _getLevel('pacifist') * 0.05; // 5% por nível (0.05 a 0.50)
  
  bool get hasSurvivorBonus => _getLevel('survivor') > 0;
  
  double get goldenMoleChance => _getLevel('golden_mole') * 0.05; // 5% por nível (0.05 a 0.15)

  int _getLevel(String id) {
    return upgrades.firstWhere((u) => u.id == id).level;
  }

  void addCoins(int amount) {
    coins += amount;
    notifyListeners();
  }

  void buyUpgrade(String id) {
    final upgrade = upgrades.firstWhere((u) => u.id == id);
    
    // Verifica se tem dinheiro e se não atingiu o nível máximo
    if (coins >= upgrade.cost && upgrade.level < upgrade.maxLevel) {
      coins -= upgrade.cost;
      upgrade.level++;

      // Efeitos estáticos de upgrades que afetam variáveis globais
      if (id == 'time') extraMoleTimeMs += 200;
      if (id == 'golden_mallet') coinMultiplier += 1;

      // Define o preço da próxima compra
      if (upgrade.level < upgrade.maxLevel) {
        if (upgrade.customCosts != null) {
          upgrade.cost = upgrade.customCosts![upgrade.level];
        } else {
          // Escala de preço padrão (ex: +50% mais caro) se não houver customCosts
          upgrade.cost = (upgrade.cost * 1.5).toInt(); 
        }
      }
      notifyListeners();
    }
  }
}