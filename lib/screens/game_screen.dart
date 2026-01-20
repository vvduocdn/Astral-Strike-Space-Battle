import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/player_data.dart';
import '../models/mission.dart';
import '../game/space_shooter_game.dart';
import '../game/managers/audio_manager.dart';
import 'mission_briefing_screen.dart';

class GameScreen extends StatefulWidget {
  final PlayerData playerData;
  final int? startLevel;
  final Mission? mission; // Optional mission parameter

  const GameScreen({
    super.key,
    required this.playerData,
    this.startLevel,
    this.mission,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SpaceShooterGame _game;
  bool _showPauseMenu = false;
  bool _showGameOver = false;
  bool _showLevelComplete = false;
  bool _showBossWarning = false;
  bool _showMissionStart = false;

  @override
  void initState() {
    super.initState();
    _game = SpaceShooterGame(
      playerData: widget.playerData,
      mission: widget.mission,
    );

    // Set level if provided
    if (widget.startLevel != null) {
      _game.currentLevel = widget.startLevel!;
    }

    _game.onPause = () => setState(() => _showPauseMenu = true);
    _game.onGameOver = () => setState(() => _showGameOver = true);
    _game.onLevelComplete = () => setState(() => _showLevelComplete = true);

    // Show mission start popup if in mission mode
    if (widget.mission != null) {
      _showMissionStart = true;
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() => _showMissionStart = false);
        }
      });
    }
  }

  @override
  void dispose() {
    // Stop all SFX when leaving game screen
    AudioManager().onExitGame();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: Stack(
        children: [
          // Game
          GameWidget(game: _game),

          // HUD
          SafeArea(
            child: _buildHUD(),
          ),

          // Mission Objectives (if in mission mode) - Compact version on the side
          if (widget.mission != null)
            Positioned(
              top: 80,
              right: 8,
              child: _buildCompactObjectives(),
            ),

          // Bomb Button
          Positioned(
            right: 20,
            bottom: 100,
            child: _buildBombButton(),
          ),

          // Mission Start Popup
          if (_showMissionStart) _buildMissionStartPopup(),

          // Boss Warning
          if (_game.gameState == GameState.bossWarning)
            _buildBossWarning(),

          // Pause Menu
          if (_showPauseMenu) _buildPauseMenu(),

          // Game Over
          if (_showGameOver) _buildGameOver(),

          // Level Complete
          if (_showLevelComplete) _buildLevelComplete(),
        ],
      ),
    );
  }

  Widget _buildBombButton() {
    return ValueListenableBuilder<int>(
      valueListenable: _game.bombNotifier,
      builder: (context, bombCount, _) {
        return GestureDetector(
          onTap: bombCount > 0 ? _useBomb : null,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bombCount > 0
                  ? GameColors.danger.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              border: Border.all(
                color: bombCount > 0 ? GameColors.danger : Colors.grey,
                width: 3,
              ),
              boxShadow: bombCount > 0
                  ? [
                      BoxShadow(
                        color: GameColors.danger.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.flash_on,
                  color: bombCount > 0 ? GameColors.warning : Colors.grey,
                  size: 30,
                ),
                Text(
                  'x$bombCount',
                  style: TextStyle(
                    color: bombCount > 0 ? GameColors.text : Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _useBomb() {
    _game.useBomb();
  }

  Widget _buildHUD() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Pause button
              IconButton(
                onPressed: _pauseGame,
                icon: const Icon(Icons.pause, color: GameColors.text, size: 32),
              ),

              // Score
              ValueListenableBuilder<int>(
                valueListenable: _game.scoreNotifier,
                builder: (context, score, _) {
                  return Text(
                    'SCORE: $score',
                    style: const TextStyle(
                      color: GameColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),

              // Coins
              ValueListenableBuilder<int>(
                valueListenable: _game.coinsNotifier,
                builder: (context, coins, _) {
                  return Row(
                    children: [
                      const Icon(Icons.monetization_on,
                          color: GameColors.coin, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '$coins',
                        style: const TextStyle(
                          color: GameColors.coin,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Level/Mission info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.mission != null)
                // Mission mode - show mission title
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: GameColors.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: GameColors.secondary.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    'MISSION ${widget.mission!.id}',
                    style: const TextStyle(
                      color: GameColors.secondary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                // Normal mode - show level
                ValueListenableBuilder<int>(
                  valueListenable: _game.levelNotifier,
                  builder: (context, level, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: GameColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: GameColors.primary.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        'LEVEL $level',
                        style: const TextStyle(
                          color: GameColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),

          const Spacer(),

          // Health bar
          ValueListenableBuilder<int>(
            valueListenable: _game.healthNotifier,
            builder: (context, health, _) {
              final maxHealth = widget.playerData.maxHealth;
              final healthPercent = health / maxHealth;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'HEALTH',
                          style: TextStyle(
                            color: GameColors.text,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$health/$maxHealth',
                          style: const TextStyle(
                            color: GameColors.text,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: GameColors.backgroundLight,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: healthPercent.clamp(0, 1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: healthPercent > 0.5
                                ? GameColors.success
                                : healthPercent > 0.25
                                    ? GameColors.warning
                                    : GameColors.danger,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMissionStartPopup() {
    if (widget.mission == null) return const SizedBox.shrink();

    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: GameColors.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GameColors.secondary, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MISSION ${widget.mission!.id}',
                style: const TextStyle(
                  color: GameColors.secondary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.mission!.title.toUpperCase(),
                style: const TextStyle(
                  color: GameColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'OBJECTIVES:',
                style: TextStyle(
                  color: GameColors.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              ...widget.mission!.objectives.map((obj) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.flag,
                      color: GameColors.accent,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        obj.description,
                        style: const TextStyle(
                          color: GameColors.text,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              const Text(
                'Good luck, pilot!',
                style: TextStyle(
                  color: GameColors.textDark,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBossWarning() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.2),
              duration: const Duration(milliseconds: 500),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: const Text(
                'WARNING',
                style: TextStyle(
                  color: GameColors.danger,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'BOSS APPROACHING',
              style: TextStyle(
                color: GameColors.warning,
                fontSize: 24,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseMenu() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                color: GameColors.text,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 40),
            _buildDialogButton('RESUME', GameColors.primary, _resumeGame),
            const SizedBox(height: 16),
            _buildDialogButton('RESTART', GameColors.warning, _restartGame),
            const SizedBox(height: 16),
            _buildDialogButton('QUIT', GameColors.danger, _quitGame),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOver() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                color: GameColors.danger,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<int>(
              valueListenable: _game.scoreNotifier,
              builder: (context, score, _) {
                return Text(
                  'SCORE: $score',
                  style: const TextStyle(
                    color: GameColors.text,
                    fontSize: 32,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Text(
              'HIGH SCORE: ${widget.playerData.highScore}',
              style: const TextStyle(
                color: GameColors.coin,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 40),
            _buildDialogButton('RETRY', GameColors.primary, _restartGame),
            const SizedBox(height: 16),
            _buildDialogButton('QUIT', GameColors.danger, _quitGame),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelComplete() {
    final isMissionMode = widget.mission != null;

    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isMissionMode ? 'MISSION COMPLETE!' : 'LEVEL COMPLETE!',
              style: const TextStyle(
                color: GameColors.success,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<int>(
              valueListenable: _game.scoreNotifier,
              builder: (context, score, _) {
                return Text(
                  'SCORE: $score',
                  style: const TextStyle(
                    color: GameColors.text,
                    fontSize: 28,
                  ),
                );
              },
            ),
            if (isMissionMode && widget.mission != null) ...[
              const SizedBox(height: 10),
              Text(
                '+${widget.mission!.rewardCoins} COINS',
                style: const TextStyle(
                  color: GameColors.coin,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Show stars earned
              _buildStarsDisplay(),
            ],
            const SizedBox(height: 40),
            // Normal mode: Next Level button
            if (!isMissionMode) ...[
              _buildDialogButton('NEXT LEVEL', GameColors.primary, _nextLevel),
              const SizedBox(height: 16),
              _buildDialogButton('MAIN MENU', GameColors.danger, _quitGame),
            ],
            // Mission mode: Different options
            if (isMissionMode) ...[
              _buildDialogButton('NEXT MISSION', GameColors.primary, _nextMission),
              const SizedBox(height: 16),
              _buildDialogButton('MISSIONS', GameColors.secondary, _quitGame),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStarsDisplay() {
    // Get stars earned from mission manager
    final stars = _game.missionManager?.getProgressForMission(widget.mission!.id)?.starsEarned ?? 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Icon(
          index < stars ? Icons.star : Icons.star_border,
          color: GameColors.warning,
          size: 32,
        );
      }),
    );
  }

  Widget _buildCompactObjectives() {
    if (widget.mission == null || _game.missionManager == null) {
      return const SizedBox.shrink();
    }

    final mission = _game.missionManager!.currentMission;
    if (mission == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: GameColors.backgroundLight.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GameColors.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: mission.objectives.map((obj) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  obj.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: obj.isCompleted ? GameColors.success : GameColors.textDark,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  '${obj.currentValue}/${obj.targetValue}',
                  style: TextStyle(
                    color: obj.isCompleted ? GameColors.success : GameColors.text,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDialogButton(String text, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 200,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _pauseGame() {
    AudioManager().playButtonClick();
    _game.pauseGame();
  }

  void _resumeGame() {
    AudioManager().playButtonClick();
    setState(() => _showPauseMenu = false);
    _game.resumeGame();
  }

  void _restartGame() {
    AudioManager().playButtonClick();
    setState(() {
      _showPauseMenu = false;
      _showGameOver = false;
    });
    _game.restartGame();
  }

  void _nextLevel() {
    AudioManager().playMenuSelect();
    setState(() => _showLevelComplete = false);
    _game.continueToNextLevel();
  }

  void _nextMission() {
    if (widget.mission == null) return;

    AudioManager().playButtonClick();

    // Get next mission ID
    final nextMissionId = widget.mission!.id + 1;

    // Load mission manager to check if next mission exists
    final missionManager = _game.missionManager;
    if (missionManager == null) {
      _quitGame();
      return;
    }

    final nextMission = missionManager.getMissionById(nextMissionId);

    // Check if next mission is unlocked
    if (nextMission != null && missionManager.isMissionUnlocked(nextMissionId)) {
      // Stop current game and navigate to next mission briefing
      AudioManager().onExitGame();
      widget.playerData.save();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MissionBriefingScreen(
            mission: nextMission,
            playerData: widget.playerData,
          ),
        ),
      );
    } else {
      // No more missions or next mission locked, go back to mission select
      _quitGame();
    }
  }

  void _quitGame() {
    AudioManager().playButtonClick();
    // Stop all SFX but keep background music
    AudioManager().onExitGame();
    widget.playerData.save();
    Navigator.pop(context);
  }
}
