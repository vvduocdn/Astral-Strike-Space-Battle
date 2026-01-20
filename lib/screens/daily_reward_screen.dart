import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/player_data.dart';

class DailyRewardScreen extends StatefulWidget {
  final PlayerData playerData;

  const DailyRewardScreen({super.key, required this.playerData});

  @override
  State<DailyRewardScreen> createState() => _DailyRewardScreenState();
}

class _DailyRewardScreenState extends State<DailyRewardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  bool _claimed = false;
  int _rewardCoins = 0;

  final List<_DailyReward> _rewards = [
    _DailyReward(day: 1, coins: 50, icon: Icons.monetization_on),
    _DailyReward(day: 2, coins: 75, icon: Icons.monetization_on),
    _DailyReward(day: 3, coins: 100, icon: Icons.monetization_on),
    _DailyReward(day: 4, coins: 150, icon: Icons.card_giftcard),
    _DailyReward(day: 5, coins: 200, icon: Icons.monetization_on),
    _DailyReward(day: 6, coins: 300, icon: Icons.card_giftcard),
    _DailyReward(day: 7, coins: 500, icon: Icons.auto_awesome, isSpecial: true),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    _checkAndClaimReward();
  }

  void _checkAndClaimReward() {
    final now = DateTime.now();
    final lastReward = widget.playerData.lastDailyReward;

    if (lastReward == null) {
      widget.playerData.dailyRewardStreak = 1;
    } else {
      final hoursSinceLastReward = now.difference(lastReward).inHours;

      if (hoursSinceLastReward >= 24 && hoursSinceLastReward < 48) {
        widget.playerData.dailyRewardStreak++;
      } else if (hoursSinceLastReward >= 48) {
        widget.playerData.dailyRewardStreak = 1;
      }
    }

    if (widget.playerData.dailyRewardStreak > 7) {
      widget.playerData.dailyRewardStreak = 1;
    }

    _animController.forward();
  }

  void _claimReward() {
    if (_claimed) return;

    final dayIndex = (widget.playerData.dailyRewardStreak - 1).clamp(0, 6);
    final reward = _rewards[dayIndex];

    setState(() {
      _claimed = true;
      _rewardCoins = reward.coins;
      widget.playerData.coins += reward.coins;
      widget.playerData.lastDailyReward = DateTime.now();
    });

    widget.playerData.save();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentDay = widget.playerData.dailyRewardStreak;

    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: GameColors.text, size: 32),
              ),
            ),

            const Spacer(),

            // Title
            ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                children: [
                  const Icon(
                    Icons.card_giftcard,
                    color: GameColors.coin,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'DAILY REWARD',
                    style: TextStyle(
                      color: GameColors.text,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Day $currentDay of 7',
                    style: const TextStyle(
                      color: GameColors.textDark,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Reward grid
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(7, (index) {
                  final day = index + 1;
                  final reward = _rewards[index];
                  final isToday = day == currentDay;
                  final isPast = day < currentDay;

                  return _buildDayTile(day, reward, isToday, isPast);
                }),
              ),
            ),

            const SizedBox(height: 40),

            // Claim button or reward display
            if (!_claimed)
              ElevatedButton(
                onPressed: _claimReward,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameColors.coin,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'CLAIM REWARD',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              )
            else
              Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: GameColors.success,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '+$_rewardCoins COINS',
                    style: const TextStyle(
                      color: GameColors.coin,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'CONTINUE',
                      style: TextStyle(
                        color: GameColors.primary,
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildDayTile(int day, _DailyReward reward, bool isToday, bool isPast) {
    Color bgColor;
    Color borderColor;

    if (isToday) {
      bgColor = GameColors.coin.withOpacity(0.3);
      borderColor = GameColors.coin;
    } else if (isPast) {
      bgColor = GameColors.success.withOpacity(0.2);
      borderColor = GameColors.success;
    } else {
      bgColor = GameColors.backgroundLight;
      borderColor = GameColors.textDark.withOpacity(0.3);
    }

    return Container(
      width: 44,
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: isToday ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$day',
            style: TextStyle(
              color: isToday ? GameColors.coin : GameColors.text,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          if (isPast)
            const Icon(Icons.check, color: GameColors.success, size: 18)
          else
            Icon(
              reward.icon,
              color: isToday
                  ? GameColors.coin
                  : reward.isSpecial
                      ? GameColors.accent
                      : GameColors.textDark,
              size: 18,
            ),
          const SizedBox(height: 2),
          Text(
            '${reward.coins}',
            style: TextStyle(
              color: isToday ? GameColors.coin : GameColors.textDark,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyReward {
  final int day;
  final int coins;
  final IconData icon;
  final bool isSpecial;

  _DailyReward({
    required this.day,
    required this.coins,
    required this.icon,
    this.isSpecial = false,
  });
}
