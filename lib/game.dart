import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'game_state.dart';
import 'shop.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // --- Estado do Jogo (Local) ---
  int survivalSeconds = 0;
  bool isGameOver = false;
  
  // --- Posição e Estado da Toupeira ---
  bool isMoleVisible = false;
  double moleX = 0.0;
  double moleY = 0.0;

  // --- Cronômetros ---
  Timer? survivalTimer;
  Timer? nextMoleTimer; // Substitui o moleSpawnerTimer fixo
  Timer? moleDespawnTimer;

  final Random random = Random();

  // --- Parâmetros de Dificuldade ---
  // Valores iniciais
  final double startSpawnRateMs = 2000.0; 
  final double startUptimeMs = 1500.0;
  
  // Limites mínimos (para o jogo não ficar impossível)
  final double minSpawnRateMs = 600.0;
  final double minUptimeMs = 400.0;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    setState(() {
      survivalSeconds = 0;
      isMoleVisible = false;
      isGameOver = false;
    });

    // Cronômetro de sobrevivência
    survivalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isGameOver) {
        setState(() {
          survivalSeconds++;
        });
      }
    });

    // Inicia o ciclo de spawn
    scheduleNextMole();
  }

  // --- Lógica da Curva de Dificuldade ---
  void scheduleNextMole() {
    if (isGameOver) return;

    // A cada segundo que passa, diminuímos os milissegundos.
    // Ex: A cada segundo, o spawn fica 15ms mais rápido.
    double calculatedSpawnRate = startSpawnRateMs - (survivalSeconds * 15);
    int currentSpawnDelay = max(minSpawnRateMs.toInt(), calculatedSpawnRate.toInt());

    nextMoleTimer = Timer(Duration(milliseconds: currentSpawnDelay), () {
      spawnMole();
    });
  }

  void spawnMole() {
    if (isGameOver) return;

    setState(() {
      moleX = (random.nextDouble() * 1.7) - 0.85;
      moleY = (random.nextDouble() * 1.7) - 0.85;
      isMoleVisible = true;
    });

    // Calcula o tempo que ela fica na tela (diminuindo com o tempo)
    double calculatedUptime = startUptimeMs - (survivalSeconds * 10);
    int difficultyBaseUptime = max(minUptimeMs.toInt(), calculatedUptime.toInt());

    // Aplica o Upgrade da Loja sobre a dificuldade atual
    final gameState = Provider.of<GameState>(context, listen: false);
    int totalUptime = difficultyBaseUptime + gameState.extraMoleTimeMs;

    moleDespawnTimer?.cancel();
    moleDespawnTimer = Timer(Duration(milliseconds: totalUptime), () {
      if (isMoleVisible && !isGameOver) {
        triggerGameOver();
      } else if (!isGameOver) {
        // Se a toupeira foi acertada ou sumiu, agenda a próxima
        scheduleNextMole();
      }
    });
  }

  void whack() {
    if (isGameOver || !isMoleVisible) return;

    moleDespawnTimer?.cancel(); 
    
    final gameState = Provider.of<GameState>(context, listen: false);
    gameState.addCoins(gameState.coinMultiplier);

    setState(() {
      isMoleVisible = false;
    });

    // Agenda a próxima toupeira imediatamente após o acerto
    scheduleNextMole();
  }

  void triggerGameOver() {
    setState(() {
      isGameOver = true;
      isMoleVisible = false;
    });

    survivalTimer?.cancel();
    nextMoleTimer?.cancel();
    moleDespawnTimer?.cancel();

    showGameOverModal();
  }

  void showGameOverModal() {
    final currentCoins = Provider.of<GameState>(context, listen: false).coins;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85), // Fundo bem escuro para focar no modal
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Deixamos transparente para desenhar nosso próprio fundo
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.brown[900], // Fundo escuro estilo painel de madeira
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.orange[400]!, width: 4), // Borda chamativa
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ajusta o tamanho da coluna ao conteúdo
              children: [
                // --- Título ---
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
                
                // --- Caixa de Estatísticas ---
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.brown[700],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.brown[600]!, width: 2),
                  ),
                  child: Column(
                    children: [
                      // Tempo
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
                      // Moedas
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
                
                // --- Botões ---
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
      body: Container(
        width: double.infinity,  // <-- ADICIONE ISTO
        height: double.infinity, // <-- ADICIONE ISTO
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/grass.jpeg'), // Confirme se é .jpeg, .jpg ou .png
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Toupeira e Buraco
            if (isMoleVisible)
              Align(
                alignment: Alignment(moleX, moleY),
                child: GestureDetector(
                  onTap: whack,
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 30,
                          margin: const EdgeInsets.only(top: 60),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        AnimatedScale(
                          scale: isMoleVisible ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOutBack,
                          child: const Text('🐹', style: TextStyle(fontSize: 70)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            // HUD (Interface)
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