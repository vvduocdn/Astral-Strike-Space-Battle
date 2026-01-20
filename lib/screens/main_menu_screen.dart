import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/player_data.dart';
import '../game/managers/audio_manager.dart';
import 'game_screen.dart';
import 'shop_screen.dart';
import 'achievements_screen.dart';
import 'level_select_screen.dart';
import 'mission_select_screen.dart';
import 'settings_screen.dart';
import 'daily_reward_screen.dart';
import 'game_rules_screen.dart';
import 'policy_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  PlayerData? _playerData;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _slideAnim = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _loadPlayerData();
    _animController.forward();
  }

  Future<void> _loadPlayerData() async {
    final data = await PlayerData.load();
    setState(() => _playerData = data);

    // Check daily reward
    if (_playerData != null) {
      final now = DateTime.now();
      final lastReward = _playerData!.lastDailyReward;

      if (lastReward == null ||
          now.difference(lastReward).inHours >= 24) {
        if (mounted) {
          _showDailyReward();
        }
      }
    }
  }

  void _showDailyReward() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyRewardScreen(playerData: _playerData!),
      ),
    ).then((_) => _loadPlayerData());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: Stack(
        children: [
          // Animated background
          _buildBackground(),

          // Content
          SafeArea(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnim.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnim.value),
                    child: child,
                  ),
                );
              },
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0a0a1a),
            GameColors.background,
            Color(0xFF0d1525),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _StarsPainter(),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        const SizedBox(height: 40),

        // Title
        _buildTitle(),

        const SizedBox(height: 20),

        // Stats bar
        if (_playerData != null) _buildStatsBar(),

        const Spacer(),

        // Menu buttons
        _buildMenuButtons(),

        const SizedBox(height: 40),

        // Bottom buttons
        _buildBottomButtons(),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [GameColors.primary, GameColors.accent],
          ).createShader(bounds),
          child: const Text(
            'ASTRAL',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 8,
            ),
          ),
        ),
        const Text(
          'STRIKE',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: GameColors.text,
            letterSpacing: 10,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'SPACE BATTLE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: GameColors.textDark,
            letterSpacing: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: GameColors.backgroundLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GameColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(Icons.monetization_on, '${_playerData!.coins}', GameColors.coin),
          _buildStat(Icons.emoji_events, '${_playerData!.highScore}', GameColors.warning),
          _buildStat(Icons.star, 'Lv ${_playerData!.maxUnlockedLevel}', GameColors.primary),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          _MenuButton(
            text: 'PLAY',
            icon: Icons.play_arrow,
            color: GameColors.primary,
            onTap: () => _startGame(),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            text: 'STORY MISSIONS',
            icon: Icons.auto_stories,
            color: Color(0xFFFF6B35), // Orange color
            onTap: () => _openMissions(),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            text: 'SELECT LEVEL',
            icon: Icons.grid_view,
            color: GameColors.secondary,
            onTap: () => _openLevelSelect(),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            text: 'SHOP',
            icon: Icons.shopping_cart,
            color: GameColors.accent,
            onTap: () => _openShop(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _IconButton(
          icon: Icons.emoji_events,
          onTap: () => _openAchievements(),
        ),
        const SizedBox(width: 16),
        _IconButton(
          icon: Icons.card_giftcard,
          onTap: () => _showDailyReward(),
        ),
        const SizedBox(width: 16),
        _IconButton(
          icon: Icons.menu_book,
          onTap: () => _openGameRules(),
        ),
        const SizedBox(width: 16),
        _IconButton(
          icon: Icons.settings,
          onTap: () => _openSettings(),
        ),
      ],
    );
  }

  void _startGame() {
    if (_playerData == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          playerData: _playerData!,
          startLevel: _playerData!.currentLevel,
        ),
      ),
    ).then((_) => _loadPlayerData());
  }

  void _openMissions() {
    if (_playerData == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MissionSelectScreen(playerData: _playerData!),
      ),
    ).then((_) => _loadPlayerData());
  }

  void _openLevelSelect() {
    if (_playerData == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LevelSelectScreen(playerData: _playerData!),
      ),
    ).then((_) => _loadPlayerData());
  }

  void _openShop() {
    if (_playerData == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopScreen(playerData: _playerData!),
      ),
    ).then((_) => _loadPlayerData());
  }

  void _openAchievements() {
    if (_playerData == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AchievementsScreen(playerData: _playerData!),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _openGameRules() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GameRulesScreen(),
      ),
    );
  }

  void _openPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PolicyScreen(),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AudioManager().playButtonClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AudioManager().playButtonClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: GameColors.backgroundLight.withOpacity(0.5),
            border: Border.all(color: GameColors.primary.withOpacity(0.3)),
          ),
          child: Icon(icon, color: GameColors.text, size: 24),
        ),
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < 100; i++) {
      final x = ((random * (i + 1)) % size.width.toInt()).toDouble();
      final y = ((random * (i + 7)) % size.height.toInt()).toDouble();
      final radius = (i % 3) * 0.5 + 0.5;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint..color = Colors.white.withOpacity(0.3 + (i % 5) * 0.1),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
