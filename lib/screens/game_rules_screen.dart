import 'package:flutter/material.dart';
import '../utils/constants.dart';

class GameRulesScreen extends StatelessWidget {
  const GameRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      appBar: AppBar(
        backgroundColor: GameColors.backgroundLight,
        title: const Text('GAME RULES', style: TextStyle(letterSpacing: 2)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHowToPlay(),
            const SizedBox(height: 24),
            _buildPowerUpRules(),
            const SizedBox(height: 24),
            _buildWeaponRules(),
            const SizedBox(height: 24),
            _buildEnemyRules(),
            const SizedBox(height: 24),
            _buildLevelRules(),
            const SizedBox(height: 24),
            _buildTips(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHowToPlay() {
    return _buildSection(
      'HOW TO PLAY',
      Icons.videogame_asset,
      GameColors.primary,
      [
        _RuleItem(
          icon: Icons.touch_app,
          title: 'Movement',
          description: 'Drag your finger on the screen to move your spaceship. The ship follows your touch.',
        ),
        _RuleItem(
          icon: Icons.flash_on,
          title: 'Auto Fire',
          description: 'Your ship fires automatically. Focus on dodging enemy attacks and collecting power-ups.',
        ),
        _RuleItem(
          icon: Icons.local_fire_department,
          title: 'Bomb',
          description: 'Tap the bomb button to clear all enemies and bullets on screen. Use wisely!',
        ),
        _RuleItem(
          icon: Icons.favorite,
          title: 'Lives',
          description: 'You start with 3 lives. Lose all health to lose a life. Game over when all lives are lost.',
        ),
      ],
    );
  }

  Widget _buildPowerUpRules() {
    return _buildSection(
      'POWER-UP RULES',
      Icons.bolt,
      GameColors.warning,
      [
        _RuleItem(
          icon: Icons.favorite,
          title: 'Health (Red Heart)',
          description: 'Restores 30 HP. Collect when your health is low to survive longer.',
          color: GameColors.health,
        ),
        _RuleItem(
          icon: Icons.shield,
          title: 'Shield (Blue Shield)',
          description: 'Grants temporary invincibility for 5 seconds. You cannot take damage while shielded.',
          color: GameColors.shield,
        ),
        _RuleItem(
          icon: Icons.upgrade,
          title: 'Weapon Upgrade (Orange Arrow)',
          description: 'Temporarily upgrades your weapon power for 10 seconds. Deals more damage!',
          color: GameColors.secondary,
        ),
        _RuleItem(
          icon: Icons.speed,
          title: 'Speed Boost (Green Lightning)',
          description: 'Increases movement speed by 50% for 8 seconds. Dodge enemies more easily!',
          color: GameColors.success,
        ),
        _RuleItem(
          icon: Icons.stars,
          title: 'Score Multiplier (Yellow Star)',
          description: 'Doubles your score for 15 seconds. Great for high score runs!',
          color: GameColors.coin,
        ),
        _RuleItem(
          icon: Icons.local_fire_department,
          title: 'Bomb (Purple Bomb)',
          description: 'Adds +1 bomb to your inventory (max 5). Bombs clear all enemies on screen.',
          color: GameColors.accent,
        ),
      ],
    );
  }

  Widget _buildWeaponRules() {
    return _buildSection(
      'WEAPON TYPES',
      Icons.gps_fixed,
      GameColors.secondary,
      [
        _RuleItem(
          icon: Icons.horizontal_rule,
          title: 'Laser',
          description: 'Basic weapon. Fast fire rate, moderate damage. Good for beginners.',
          color: GameColors.primary,
        ),
        _RuleItem(
          icon: Icons.call_split,
          title: 'Spread',
          description: 'Fires 3 bullets in a spread pattern. Great for hitting multiple enemies.',
          color: GameColors.success,
        ),
        _RuleItem(
          icon: Icons.rocket,
          title: 'Missile',
          description: 'Slow fire rate but high damage. Effective against bosses and tanks.',
          color: GameColors.secondary,
        ),
        _RuleItem(
          icon: Icons.radio_button_checked,
          title: 'Plasma',
          description: 'Energy projectiles that pierce through enemies. Hits multiple targets.',
          color: GameColors.accent,
        ),
        _RuleItem(
          icon: Icons.bolt,
          title: 'Thunder',
          description: 'Chain lightning that jumps between enemies. Maximum destruction!',
          color: GameColors.warning,
        ),
      ],
    );
  }

  Widget _buildEnemyRules() {
    return _buildSection(
      'ENEMY TYPES',
      Icons.bug_report,
      GameColors.danger,
      [
        _RuleItem(
          icon: Icons.circle,
          title: 'Basic Enemy',
          description: 'Standard enemy. Moves straight down. Easy to defeat.',
          color: GameColors.textDark,
        ),
        _RuleItem(
          icon: Icons.speed,
          title: 'Fast Enemy',
          description: 'Quick movement. Low health but hard to hit.',
          color: GameColors.success,
        ),
        _RuleItem(
          icon: Icons.shield,
          title: 'Tank Enemy',
          description: 'Slow but heavily armored. Takes many hits to destroy.',
          color: GameColors.secondary,
        ),
        _RuleItem(
          icon: Icons.gps_fixed,
          title: 'Shooter Enemy',
          description: 'Fires bullets at you! Stay mobile to avoid their attacks.',
          color: GameColors.danger,
        ),
        _RuleItem(
          icon: Icons.trending_up,
          title: 'Zigzag Enemy',
          description: 'Moves in unpredictable zigzag patterns. Tricky to hit!',
          color: GameColors.accent,
        ),
        _RuleItem(
          icon: Icons.dangerous,
          title: 'BOSS',
          description: 'Appears every 5 levels. Massive health, multiple attack patterns. Defeat for big rewards!',
          color: GameColors.warning,
        ),
      ],
    );
  }

  Widget _buildLevelRules() {
    return _buildSection(
      'LEVEL SYSTEM',
      Icons.trending_up,
      GameColors.accent,
      [
        _RuleItem(
          icon: Icons.looks_one,
          title: 'Progression',
          description: 'Defeat enough enemies to complete each level. Enemy count increases each level.',
        ),
        _RuleItem(
          icon: Icons.star,
          title: 'Boss Levels',
          description: 'Every 5th level features an epic boss battle. 50 levels total with 10 unique bosses!',
        ),
        _RuleItem(
          icon: Icons.lock_open,
          title: 'Unlocking',
          description: 'Complete a level to unlock the next. Your progress is saved automatically.',
        ),
        _RuleItem(
          icon: Icons.local_fire_department,
          title: 'Bomb Reward',
          description: 'Receive +1 bomb (up to max 5) when completing each level.',
        ),
      ],
    );
  }

  Widget _buildTips() {
    return _buildSection(
      'PRO TIPS',
      Icons.lightbulb,
      GameColors.coin,
      [
        _RuleItem(
          icon: Icons.priority_high,
          title: 'Prioritize Power-ups',
          description: 'Health and Shield power-ups are most valuable. Don\'t miss them!',
        ),
        _RuleItem(
          icon: Icons.save,
          title: 'Save Bombs',
          description: 'Save bombs for emergencies or boss battles when screen gets crowded.',
        ),
        _RuleItem(
          icon: Icons.shopping_cart,
          title: 'Upgrade Wisely',
          description: 'Visit the shop to upgrade weapons and stats. Health upgrades help survival.',
        ),
        _RuleItem(
          icon: Icons.calendar_today,
          title: 'Daily Rewards',
          description: 'Login daily to collect bonus coins. Streak bonuses give extra rewards!',
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, List<_RuleItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: GameColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          // Items
          ...items.map((item) => _buildRuleItem(item)),
        ],
      ),
    );
  }

  Widget _buildRuleItem(_RuleItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: GameColors.background.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (item.color ?? GameColors.primary).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.icon,
              color: item.color ?? GameColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: item.color ?? GameColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: GameColors.textDark,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleItem {
  final IconData icon;
  final String title;
  final String description;
  final Color? color;

  _RuleItem({
    required this.icon,
    required this.title,
    required this.description,
    this.color,
  });
}
