# Bata na Toupeira - Mole Game

Um jogo interativo desenvolvido em Flutter que combina mecânicas de clicker games com gerenciamento avançado de estado. O projeto exemplifica boas práticas em desenvolvimento mobile, incluindo state management com Provider, implementação de game loops e sistemas de progressão.

**Whack-a-Mole interactive game built with Flutter, showcasing best practices in state management, game mechanics, and mobile app architecture.**

---

## Visão Geral | Overview

### Mecânicas do Jogo | Game Mechanics
- **Clicar em Toupeiras**: Bata nas toupeiras que aparecem aleatoriamente na tela
- **Sistema de Moedas**: Ganhe moedas por cada acerto e gaste-as na loja
- **Curva de Dificuldade Dinâmica**: A dificuldade aumenta com o tempo de sobrevivência
- **Melhorias Progressivas**: Compre upgrades na loja para melhorar suas habilidades
- **Feedback Sonoro**: Efeitos de som para ações do jogador

| Feature | Description |
|---------|-------------|
| **Click-based Gameplay** | Hit moles appearing randomly on screen |
| **Coin System** | Earn coins for each successful hit and spend them in the shop |
| **Dynamic Difficulty** | Difficulty increases as survival time increases |
| **Progressive Upgrades** | Purchase upgrades in the shop to enhance abilities |
| **Audio Feedback** | Sound effects for player actions |

---

## Tópicos Estudados | Topics Covered

Este projeto foi desenvolvido para estudar e praticar os seguintes conceitos:

### 1. **State Management com Provider**
- `ChangeNotifier` para gerenciar estado global da aplicação
- Acesso e atualização de estado em múltiplas telas
- Persistência de dados do jogador (moedas, upgrades)

### 2. **Game Development & Game Loops**
- Implementação de timers e loops de jogo
- Spawning dinâmico de entidades (toupeiras)
- Curva de dificuldade logarítmica/exponencial
- Gerenciamento de estados do jogo (menu, playing, game over)

### 3. **UI/UX Flutter**
- Navegação entre telas com `Navigator`
- Widgets customizados e reutilizáveis
- Layout responsivo e adaptativo
- Animações e transições

### 4. **Integração de Áudio**
- Package `audioplayers` para efeitos de som
- Diferentes sons para diferentes ações
- Feedback sensorial ao jogador

### 5. **Arquitetura e Padrões**
- Separação de responsabilidades
- Model-View padrão
- Gerenciamento eficiente de recursos (timers, listeners)

---

## Estrutura do Projeto | Project Structure

```
lib/
├── main.dart              # Ponto de entrada e configuração da app
├── game_state.dart        # Gerenciador de estado global (Provider)
├── game.dart              # Tela principal do jogo
├── menu.dart              # Menu principal
├── shop.dart              # Tela de loja de melhorias
└── audio_utils.dart       # Utilitários de áudio
```

---

## Funcionalidades Principais | Key Features

### Tela de Jogo | Game Screen
- Contador de tempo de sobrevivência
- Contador de moedas ganhas por rodada
- Spawning de toupeiras com diferentes raridades (ouro)
- Sistema de vidas (perde-se quando a toupeira escapa)
- Pausar/Retomar jogo

### Loja de Melhorias | Shop Screen
- **Martelo Dourado**: Aumenta moedas por acerto (até 10x)
- **Reflexos Lentos**: Toupeira fica mais tempo na tela
- **Pacifista**: Chance de não perder se a toupeira escapar
- **Toupeiras Múltiplas**: Aparecem múltiplas toupeiras simultaneamente
- Sistema de custo progressivo

### Menu Principal | Main Menu
- Botão para iniciar jogo
- Botão para acessar loja
- Exibição de moedas totais

---

## Dependências | Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.5+1       # State management
  audioplayers: ^6.6.0     # Audio playback
  cupertino_icons: ^1.0.8  # iOS icons

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

---

## Como Executar | How to Run

### Pré-requisitos | Prerequisites
- Flutter SDK instalado ([flutter.dev](https://flutter.dev))
- Device ou emulador Android/iOS disponível

### Passos | Steps

1. **Clone o repositório**
   ```bash
   git clone <repository-url>
   cd mole_game
   ```

2. **Instale dependências**
   ```bash
   flutter pub get
   ```

3. **Execute a aplicação**
   ```bash
   flutter run
   ```

---

## Conceitos Aprendidos | Learning Outcomes

Ao estudar este projeto, você compreenderá:

- Como estruturar um aplicativo Flutter com múltiplas telas
- Implementação de state management com Provider
- Criação de game loops em Flutter
- Gerenciamento de timers e assincronicidade
- Boas práticas em arquitetura de aplicativos mobile
- Integração de áudio e feedback sensorial
- Otimização de performance em aplicativos com alta frequência de atualizações

---

## Recursos Úteis | Useful Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [Flutter Game Development](https://docs.flutter.dev/development/games)
- [AudioPlayers Package](https://pub.dev/packages/audioplayers)

---

**Desenvolvido como estudo prático de State Management e Game Development em Flutter.**

*Developed as practical study of State Management and Game Development in Flutter.*
