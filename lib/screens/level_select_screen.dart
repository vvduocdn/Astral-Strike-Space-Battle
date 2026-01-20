import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/player_data.dart';
import '../game/managers/audio_manager.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  final PlayerData playerData;

  const LevelSelectScreen({super.key, required this.playerData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      appBar: AppBar(
        backgroundColor: GameColors.backgroundLight,
        title: const Text('SELECT LEVEL', style: TextStyle(letterSpacing: 4)),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: GameConstants.totalLevels,
        itemBuilder: (context, index) {
          final level = index + 1;
          final isUnlocked = level <= playerData.maxUnlockedLevel;
          final isBoss = level % GameConstants.bossEveryLevel == 0;
          final isCompleted = level < playerData.maxUnlockedLevel;

          return _buildLevelTile(context, level, isUnlocked, isBoss, isCompleted);
        },
      ),
    );
  }

  Widget _buildLevelTile(
    BuildContext context,
    int level,
    bool isUnlocked,
    bool isBoss,
    bool isCompleted,
  ) {
    Color tileColor;
    if (!isUnlocked) {
      tileColor = Colors.grey.shade800;
    } else if (isBoss) {
      tileColor = GameColors.danger;
    } else if (isCompleted) {
      tileColor = GameColors.success;
    } else {
      tileColor = GameColors.primary;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isUnlocked ? () => _startLevel(context, level) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: tileColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: tileColor.withOpacity(isUnlocked ? 0.8 : 0.3),
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isUnlocked)
                      Text(
                        '$level',
                        style: TextStyle(
                          color: tileColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Icon(Icons.lock, color: Colors.grey.shade600, size: 28),
                    if (isBoss && isUnlocked)
                      const Icon(
                        Icons.whatshot,
                        color: GameColors.warning,
                        size: 16,
                      ),
                  ],
                ),
              ),
              if (isCompleted)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    Icons.check_circle,
                    color: GameColors.success,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _startLevel(BuildContext context, int level) {
    AudioManager().playMenuSelect();
    playerData.currentLevel = level;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          playerData: playerData,
          startLevel: level,
        ),
      ),
    );
  }
}
