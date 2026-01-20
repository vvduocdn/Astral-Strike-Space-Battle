import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../models/player_data.dart';
import '../utils/constants.dart';
import '../game/managers/audio_manager.dart';
import '../game/managers/mission_manager.dart';
import 'mission_briefing_screen.dart';

class MissionSelectScreen extends StatefulWidget {
  final PlayerData playerData;

  const MissionSelectScreen({super.key, required this.playerData});

  @override
  State<MissionSelectScreen> createState() => _MissionSelectScreenState();
}

class _MissionSelectScreenState extends State<MissionSelectScreen>
    with SingleTickerProviderStateMixin {
  late final MissionManager _missionManager;
  late TabController _tabController;

  final List<MissionDifficulty> _difficulties = [
    MissionDifficulty.easy,
    MissionDifficulty.medium,
    MissionDifficulty.hard,
    MissionDifficulty.expert,
  ];

  @override
  void initState() {
    super.initState();
    _missionManager = MissionManager();
    _tabController = TabController(length: _difficulties.length, vsync: this);
    _loadMissionProgress();
  }

  Future<void> _loadMissionProgress() async {
    await _missionManager.load();
    if (mounted) {
      setState(() {}); // Refresh UI after loading
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getDifficultyColor(MissionDifficulty difficulty) {
    switch (difficulty) {
      case MissionDifficulty.easy:
        return GameColors.success;
      case MissionDifficulty.medium:
        return GameColors.warning;
      case MissionDifficulty.hard:
        return GameColors.secondary;
      case MissionDifficulty.expert:
        return GameColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalMissions = _missionManager.getAllMissions().length;
    final completedMissions = _missionManager.getCompletedMissionsCount();
    final totalStars = _missionManager.getTotalStarsEarned();

    return Scaffold(
      backgroundColor: GameColors.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  GameColors.backgroundLight,
                  GameColors.background,
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: GameColors.text),
                      onPressed: () {
                        AudioManager().playButtonClick();
                        Navigator.pop(context);
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'STORY MISSIONS',
                        style: TextStyle(
                          color: GameColors.text,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProgressBar(completedMissions, totalMissions, totalStars),
              ],
            ),
          ),

          // Difficulty Tabs
          Container(
            color: GameColors.backgroundLight,
            child: TabBar(
              controller: _tabController,
              indicatorColor: GameColors.primary,
              labelColor: GameColors.primary,
              unselectedLabelColor: GameColors.textDark,
              tabs: _difficulties.map((difficulty) {
                return Tab(
                  child: Text(
                    difficulty.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Mission List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _difficulties.map((difficulty) {
                return _buildMissionList(difficulty);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int completed, int total, int stars) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GameColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildProgressItem(
            Icons.check_circle,
            '$completed/$total',
            'Completed',
            GameColors.success,
          ),
          Container(width: 1, height: 30, color: GameColors.textDark),
          _buildProgressItem(
            Icons.star,
            '$stars/${total * 3}',
            'Stars',
            GameColors.warning,
          ),
          Container(width: 1, height: 30, color: GameColors.textDark),
          _buildProgressItem(
            Icons.emoji_events,
            '${(completed / total * 100).toInt()}%',
            'Progress',
            GameColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: GameColors.textDark,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildMissionList(MissionDifficulty difficulty) {
    final missions = _missionManager.getMissionsByDifficulty(difficulty);

    if (missions.isEmpty) {
      return Center(
        child: Text(
          'No ${difficulty.name} missions available',
          style: const TextStyle(
            color: GameColors.textDark,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        final progress = _missionManager.getProgressForMission(mission.id);
        final isUnlocked = _missionManager.isMissionUnlocked(mission.id);

        return _MissionCard(
          mission: mission,
          progress: progress,
          isUnlocked: isUnlocked,
          difficultyColor: _getDifficultyColor(difficulty),
          onTap: () => _onMissionTap(mission, isUnlocked),
        );
      },
    );
  }

  void _onMissionTap(Mission mission, bool isUnlocked) {
    if (!isUnlocked) {
      _showLockedDialog();
      return;
    }

    AudioManager().playButtonClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MissionBriefingScreen(
          mission: mission,
          playerData: widget.playerData,
        ),
      ),
    ).then((_) {
      setState(() {
        _missionManager.load();
      });
    });
  }

  void _showLockedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameColors.backgroundLight,
        title: const Text(
          'Mission Locked',
          style: TextStyle(color: GameColors.text),
        ),
        content: const Text(
          'Complete the previous mission to unlock this one.',
          style: TextStyle(color: GameColors.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: GameColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final Mission mission;
  final MissionProgress? progress;
  final bool isUnlocked;
  final Color difficultyColor;
  final VoidCallback onTap;

  const _MissionCard({
    required this.mission,
    required this.progress,
    required this.isUnlocked,
    required this.difficultyColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = progress?.completed ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isUnlocked ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? GameColors.backgroundLight.withOpacity(0.5)
                  : GameColors.background.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCompleted
                    ? GameColors.success.withOpacity(0.5)
                    : difficultyColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                // Mission Number
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: difficultyColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: difficultyColor),
                  ),
                  child: Center(
                    child: Text(
                      '${mission.id}',
                      style: TextStyle(
                        color: difficultyColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Mission Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mission.title.toUpperCase(),
                              style: TextStyle(
                                color: isUnlocked
                                    ? GameColors.text
                                    : GameColors.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          if (!isUnlocked)
                            const Icon(
                              Icons.lock,
                              color: GameColors.textDark,
                              size: 20,
                            ),
                          if (isCompleted)
                            const Icon(
                              Icons.check_circle,
                              color: GameColors.success,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mission.location,
                        style: const TextStyle(
                          color: GameColors.textDark,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildSmallInfo(
                            Icons.flag,
                            '${mission.objectives.length}',
                            GameColors.accent,
                          ),
                          const SizedBox(width: 12),
                          _buildSmallInfo(
                            Icons.monetization_on,
                            '${mission.rewardCoins}',
                            GameColors.coin,
                          ),
                          const SizedBox(width: 12),
                          if (isCompleted) _buildStars(progress!.starsEarned),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallInfo(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStars(int stars) {
    return Row(
      children: List.generate(3, (index) {
        return Icon(
          index < stars ? Icons.star : Icons.star_border,
          color: GameColors.warning,
          size: 16,
        );
      }),
    );
  }
}
