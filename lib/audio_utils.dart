import 'package:audioplayers/audioplayers.dart';

class AudioUtils {
  static final AudioPlayer _tapPlayer = AudioPlayer();
  static final AudioPlayer _whackPlayer = AudioPlayer();
  static final AudioPlayer _buyPlayer = AudioPlayer();

  static Future<void> playTap() async {
    try {
      await _tapPlayer.stop();
      await _tapPlayer.play(AssetSource('sounds/tap.mp3'));
    } catch (e) {
      debugPrint('Erro ao tocar som de tap: $e');
    }
  }

  static Future<void> playWhack() async {
    try {
      // Usando players diferentes para permitir sons sobrepostos sutilmente
      final player = AudioPlayer();
      await player.play(AssetSource('sounds/whack.mp3'), volume: 0.5);
      // Auto-dispose do player temporário após tocar? 
      // Audioplayers não tem um simples auto-dispose, mas para sons curtos é ok.
    } catch (e) {
      debugPrint('Erro ao tocar som de whack: $e');
    }
  }

  static Future<void> playBuy() async {
    try {
      await _buyPlayer.stop();
      await _buyPlayer.play(AssetSource('sounds/buy.mp3'));
    } catch (e) {
      debugPrint('Erro ao tocar som de compra: $e');
    }
  }
}

// Helper para evitar erro de debugPrint não importado se necessário
void debugPrint(String message) {
  print(message);
}
