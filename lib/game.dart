import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'game_state.dart';
import 'shop.dart';
import 'audio_utils.dart';

class MoleData {
  final String id;
  final double x;
  final double y;
  final bool isGolden;
  Timer? despawnTimer;

  MoleData({
    required this.id,
    required this.x,
    required this.y,
    required this.isGolden,
  });
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Estado
  int survivalSeconds = 0;
  int roundCoins = 0;
  int moleCounter = 0;
  bool isGameOver = false;
  List<MoleData> moles = [];

  Timer? survivalTimer;
  Timer? nextMoleTimer;

  final Random random = Random();

  // Parâmetros de dificuldade
  final double startSpawnRateMs = 900.0; 
  final double startUptimeMs = 1100.0;
  
  // Limites mínimos (para o jogo não ficar impossível)
  final double minSpawnRateMs = 300.0;
  final double minUptimeMs = 200.0;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    setState(() {
      survivalSeconds = 0;
      roundCoins = 0;
      isGameOver = false;
      moles = [];
    });

    // Timers da lógica do jogo
    survivalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isGameOver) {
        setState(() {
          survivalSeconds++;
        });
      }
    });

    scheduleNextMole();
  }

  // Lógica da curva de dificuldade
  void scheduleNextMole() {
    if (isGameOver) return;
    
    nextMoleTimer?.cancel();
    
    final gameState = Provider.of<GameState>(context, listen: false);
    if (moles.length >= gameState.maxMoles) return;

    double calculatedSpawnRate = startSpawnRateMs - (survivalSeconds * 15);
    int currentSpawnDelay = max(minSpawnRateMs.toInt(), calculatedSpawnRate.toInt());

    // Ajuste crucial: se o limite de toupeiras for maior que 1, 
    // precisamos spawnar mais rápido para que elas coexistam na tela.
    if (gameState.maxMoles > 1) {
      // Divide o delay pelo número de slots para forçar o preenchimento da tela
      currentSpawnDelay = (currentSpawnDelay / (gameState.maxMoles * 0.8)).toInt();
      currentSpawnDelay = max(150, currentSpawnDelay); // Limite mínimo agressivo para infestação
    }

    nextMoleTimer = Timer(Duration(milliseconds: currentSpawnDelay), () {
      spawnMole();
      scheduleNextMole(); 
    });
  }

  void spawnMole() {
    if (isGameOver) return;

    final gameState = Provider.of<GameState>(context, listen: false);
    
    // Lógica de Toupeira Dourada
    bool isGolden = random.nextDouble() < gameState.goldenMoleChance;
    
    // ID única combinando contador e timestamp para evitar chaves duplicadas
    final newMole = MoleData(
      id: 'mole_${moleCounter++}_${DateTime.now().microsecondsSinceEpoch}',
      x: (random.nextDouble() * 1.7) - 0.85,
      y: (random.nextDouble() * 1.7) - 0.85,
      isGolden: isGolden,
    );

    // Calcula o tempo que ela fica na tela
    double calculatedUptime = startUptimeMs - (survivalSeconds * 10);
    int difficultyBaseUptime = max(minUptimeMs.toInt(), calculatedUptime.toInt());
    int totalUptime = difficultyBaseUptime + gameState.extraMoleTimeMs;

    newMole.despawnTimer = Timer(Duration(milliseconds: totalUptime), () {
      if (!isGameOver) {
        bool stillActive = moles.any((m) => m.id == newMole.id);
        if (stillActive) {
          triggerGameOver(newMole.id);
        }
      }
    });

    setState(() {
      moles.add(newMole);
    });
  }

  void whack(String id) {
    if (isGameOver) return;

    final moleIndex = moles.indexWhere((m) => m.id == id);
    if (moleIndex == -1) return;

    final mole = moles[moleIndex];
    mole.despawnTimer?.cancel();
    
    AudioUtils.playWhack();
    
    final gameState = Provider.of<GameState>(context, listen: false);
    
    // Cálculo de moedas (Dourada vale 3x mais)
    int coinsEarned = gameState.coinMultiplier;
    if (mole.isGolden) {
      coinsEarned *= 3;
    }
    
    gameState.addCoins(coinsEarned);
    roundCoins += coinsEarned;

    setState(() {
      moles.removeAt(moleIndex);
    });

    // Tenta spawnar outra imediatamente se estiver abaixo do limite
    scheduleNextMole();
  }

  void triggerGameOver(String moleId) {
    final gameState = Provider.of<GameState>(context, listen: false);
    
    // Lógica do Upgrade Pacifista (chance de escapar sem morrer)
    if (random.nextDouble() < gameState.pacifistChance) {
      setState(() {
        moles.removeWhere((m) => m.id == moleId);
      });
      scheduleNextMole();
      return; 
    }

    setState(() {
      isGameOver = true;
    });

    survivalTimer?.cancel();
    nextMoleTimer?.cancel();
    for (var mole in moles) {
      mole.despawnTimer?.cancel();
    }

    // Lógica do Upgrade Sobrevivente (Dobrar ganhos se durar > 60s)
    if (survivalSeconds >= 60 && gameState.hasSurvivorBonus) {
      gameState.addCoins(roundCoins);
    }

    showGameOverModal();
  }

  void showGameOverModal() {
    final currentCoins = Provider.of<GameState>(context, listen: false).coins;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Transparente para permitir a decoração personalizada do container
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.brown[900],
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.orange[400]!, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'A TOUPEIRA ESCAPOU!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.brown[700],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.brown[600]!, width: 2),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tempo:', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              const Icon(Icons.timer, color: Colors.white, size: 22),
                              const SizedBox(width: 6),
                              Text('$survivalSeconds s', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 24, thickness: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Carteira:', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              const Icon(Icons.monetization_on, color: Colors.amber, size: 22),
                              const SizedBox(width: 6),
                              Text('$currentCoins', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.orange[600],
                          foregroundColor: Colors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          AudioUtils.playTap();
                          Navigator.of(context).pop(); 
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const ShopScreen()),
                          );
                        },
                        icon: const Icon(Icons.store, size: 24),
                        label: const Text('Loja', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          AudioUtils.playTap();
                          Navigator.of(context).pop();
                          startGame(); 
                        },
                        icon: const Icon(Icons.replay, size: 24),
                        label: const Text('Jogar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    survivalTimer?.cancel();
    nextMoleTimer?.cancel();
    for (var mole in moles) {
      mole.despawnTimer?.cancel();
    }
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/grass.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Renderiza todas as toupeiras ativas
            for (var mole in moles)
              Align(
                key: ValueKey(mole.id),
                alignment: Alignment(mole.x, mole.y),
                child: GestureDetector(
                  onTap: () => whack(mole.id),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Sombra do buraco
                        Container(
                          width: 80,
                          height: 30,
                          margin: const EdgeInsets.only(top: 60),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        // Emoji da Toupeira (Dourada ou Normal)
                        AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOutBack,
                          child: Text(
                            mole.isGolden ? '🐹' : '🐹', // Poderia usar 🐹 com filtro ou outro emoji
                            style: TextStyle(
                              fontSize: 70,
                              shadows: mole.isGolden ? [
                                const Shadow(color: Colors.amber, blurRadius: 20, offset: Offset(0, 0)),
                                const Shadow(color: Colors.orange, blurRadius: 10, offset: Offset(0, 0)),
                              ] : [],
                            ),
                          ),
                        ),
                        if (mole.isGolden)
                          const Positioned(
                            top: 0,
                            right: 0,
                            child: Icon(Icons.star, color: Colors.amber, size: 30),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer<GameState>(
                        builder: (context, gameState, child) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.monetization_on, color: Colors.amber, size: 24),
                              const SizedBox(width: 8),
                              Text('${gameState.coins}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Text(formattedTime, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}