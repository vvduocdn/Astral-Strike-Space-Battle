import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/player_data.dart';

class AchievementsScreen extends StatelessWidget {
  final PlayerData playerData;

  const AchievementsScreen({super.key, required this.playerData});

  List<_Achievement> get _achievements => [
        _Achievement(
          id: 'first_kill',
          name: 'First Blood',
          description: 'Defeat your first enemy',
          icon: Icons.military_tech,
          color: const Color(0xFFCD7F32),
          isUnlocked: playerData.totalEnemiesKilled >= 1,
        ),
        _Achievement(
          id: 'kill_100',
          name: 'Hunter',
          description: 'Defeat 100 enemies',
          icon: Icons.groups,
          color: const Color(0xFFC0C0C0),
          isUnlocked: playerData.totalEnemiesKilled >= 100,
          progress: playerData.totalEnemiesKilled / 100,
        ),
        _Achievement(
          id: 'kill_500',
          name: 'Destroyer',
          description: 'Defeat 500 enemies',
          icon: Icons.whatshot,
          color: Colors.amber,
          isUnlocked: playerData.totalEnemiesKilled >= 500,
          progress: playerData.totalEnemiesKilled / 500,
        ),
        _Achievement(
          id: 'kill_1000',
          name: 'Annihilator',
          description: 'Defeat 1000 enemies',
          icon: Icons.local_fire_department,
          color: Colors.deepOrange,
          isUnlocked: playerData.totalEnemiesKilled >= 1000,
          progress: playerData.totalEnemiesKilled / 1000,
        ),
        _Achievement(
          id: 'kill_2500',
          name: 'Exterminator',
          description: 'Defeat 2500 enemies',
          icon: Icons.flash_on,
          color: Colors.red,
          isUnlocked: playerData.totalEnemiesKilled >= 2500,
          progress: playerData.totalEnemiesKilled / 2500,
        ),
        _Achievement(
          id: 'first_boss',
          name: 'Boss Slayer',
          description: 'Defeat your first boss',
          icon: Icons.emoji_events,
          color: GameColors.warning,
          isUnlocked: playerData.totalBossesDefeated >= 1,
        ),
        _Achievement(
          id: 'boss_5',
          name: 'Champion',
          description: 'Defeat 5 bosses',
          icon: Icons.workspace_premium,
          color: GameColors.coin,
          isUnlocked: playerData.totalBossesDefeated >= 5,
          progress: playerData.totalBossesDefeated / 5,
        ),
        _Achievement(
          id: 'all_bosses',
          name: 'Boss Hunter',
          description: 'Defeat all 10 bosses',
          icon: Icons.military_tech,
          color: Colors.amber,
          isUnlocked: playerData.totalBossesDefeated >= 10,
          progress: playerData.totalBossesDefeated / 10,
        ),
        _Achievement(
          id: 'level_5',
          name: 'Getting Started',
          description: 'Reach level 5',
          icon: Icons.star_half,
          color: Colors.lightBlue,
          isUnlocked: playerData.maxUnlockedLevel >= 5,
          progress: playerData.maxUnlockedLevel / 5,
        ),
        _Achievement(
          id: 'level_10',
          name: 'Veteran',
          description: 'Reach level 10',
          icon: Icons.star,
          color: GameColors.primary,
          isUnlocked: playerData.maxUnlockedLevel >= 10,
          progress: playerData.maxUnlockedLevel / 10,
        ),
        _Achievement(
          id: 'level_20',
          name: 'Expert',
          description: 'Reach level 20',
          icon: Icons.auto_awesome,
          color: GameColors.accent,
          isUnlocked: playerData.maxUnlockedLevel >= 20,
          progress: playerData.maxUnlockedLevel / 20,
        ),
        _Achievement(
          id: 'level_35',
          name: 'Master',
          description: 'Reach level 35',
          icon: Icons.diamond,
          color: Colors.lightBlue,
          isUnlocked: playerData.maxUnlockedLevel >= 35,
          progress: playerData.maxUnlockedLevel / 35,
        ),
        _Achievement(
          id: 'level_50',
          name: 'Galactic Legend',
          description: 'Complete all 50 levels',
          icon: Icons.stars,
          color: Colors.amber,
          isUnlocked: playerData.maxUnlockedLevel >= 50,
          progress: playerData.maxUnlockedLevel / 50,
        ),
        _Achievement(
          id: 'coins_1000',
          name: 'Rich',
          description: 'Collect 1000 coins total',
          icon: Icons.monetization_on,
          color: GameColors.coin,
          isUnlocked: playerData.coins >= 1000,
          progress: playerData.coins / 1000,
        ),
        _Achievement(
          id: 'high_score_10000',
          name: 'High Scorer',
          description: 'Get a high score of 10,000',
          icon: Icons.leaderboard,
          color: GameColors.secondary,
          isUnlocked: playerData.highScore >= 10000,
          progress: playerData.highScore / 10000,
        ),
        _Achievement(
          id: 'high_score_50000',
          name: 'Legend',
          description: 'Get a high score of 50,000',
          icon: Icons.grade,
          color: Colors.purple,
          isUnlocked: playerData.highScore >= 50000,
          progress: playerData.highScore / 50000,
        ),
        _Achievement(
          id: 'daily_streak_7',
          name: 'Dedicated',
          description: 'Login 7 days in a row',
          icon: Icons.calendar_month,
          color: Colors.green,
          isUnlocked: playerData.dailyRewardStreak >= 7,
          progress: playerData.dailyRewardStreak / 7,
        ),
        _Achievement(
          id: 'weapon_max',
          name: 'Fully Armed',
          description: 'Max out any weapon',
          icon: Icons.bolt,
          color: GameColors.primary,
          isUnlocked: playerData.weaponLevels.values.any((v) => v >= 5),
        ),
        _Achievement(
          id: 'all_weapons',
          name: 'Arsenal',
          description: 'Unlock all weapons',
          icon: Icons.security,
          color: Colors.teal,
          isUnlocked: playerData.weaponLevels.values.every((v) => v > 0),
        ),
        _Achievement(
          id: 'play_time_1h',
          name: 'Time Flies',
          description: 'Play for 1 hour total',
          icon: Icons.timer,
          color: Colors.blue,
          isUnlocked: playerData.totalPlayTime >= 3600,
          progress: playerData.totalPlayTime / 3600,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final achievements = _achievements;
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    return Scaffold(
      backgroundColor: GameColors.background,
      appBar: AppBar(
        backgroundColor: GameColors.backgroundLight,
        title: const Text('ACHIEVEMENTS', style: TextStyle(letterSpacing: 4)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, color: GameColors.coin, size: 32),
                const SizedBox(width: 12),
                Text(
                  '$unlockedCount / ${achievements.length}',
                  style: const TextStyle(
                    color: GameColors.text,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Achievement list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return _buildAchievementCard(achievement);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(_Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achievement.isUnlocked
              ? achievement.color
              : Colors.grey.shade700,
          width: achievement.isUnlocked ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? achievement.color.withOpacity(0.2)
                  : Colors.grey.shade800,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              achievement.icon,
              color: achievement.isUnlocked ? achievement.color : Colors.grey,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: TextStyle(
                    color: achievement.isUnlocked
                        ? achievement.color
                        : Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: achievement.isUnlocked
                        ? GameColors.textDark
                        : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                if (achievement.progress != null && !achievement.isUnlocked)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: achievement.progress!.clamp(0, 1),
                        backgroundColor: Colors.grey.shade800,
                        valueColor: AlwaysStoppedAnimation(achievement.color),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (achievement.isUnlocked)
            const Icon(Icons.check_circle, color: GameColors.success, size: 28),
        ],
      ),
    );
  }
}

class _Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final double? progress;

  _Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.isUnlocked,
    this.progress,
  });
}
