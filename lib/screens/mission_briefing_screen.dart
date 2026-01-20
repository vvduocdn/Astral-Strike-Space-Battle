import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../models/player_data.dart';
import '../utils/constants.dart';
import '../game/managers/audio_manager.dart';
import 'game_screen.dart';

class MissionBriefingScreen extends StatefulWidget {
  final Mission mission;
  final PlayerData playerData;

  const MissionBriefingScreen({
    super.key,
    required this.mission,
    required this.playerData,
  });

  @override
  State<MissionBriefingScreen> createState() => _MissionBriefingScreenState();
}

class _MissionBriefingScreenState extends State<MissionBriefingScreen>
    with SingleTickerProviderStateMixin {
  int _currentDialogueIndex = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _nextDialogue() {
    if (_currentDialogueIndex < widget.mission.dialogue.length - 1) {
      setState(() {
        _currentDialogueIndex++;
      });
      _animController.forward(from: 0);
      AudioManager().playButtonClick();
    } else {
      _startMission();
    }
  }

  void _startMission() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          playerData: widget.playerData,
          mission: widget.mission,
        ),
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (widget.mission.difficulty) {
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
    return Scaffold(
      backgroundColor: GameColors.background,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  GameColors.background,
                  GameColors.backgroundLight,
                  GameColors.background,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Mission Title
                _buildHeader(),

                const SizedBox(height: 30),

                // Mission Info
                _buildMissionInfo(),

                const SizedBox(height: 20),

                // Objectives
                _buildObjectives(),

                const Spacer(),

                // Dialogue Box
                _buildDialogue(),

                const SizedBox(height: 20),

                // Continue Button
                _buildContinueButton(),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // Back Button
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: GameColors.text),
              onPressed: () {
                AudioManager().playButtonClick();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'MISSION ${widget.mission.id}',
          style: const TextStyle(
            color: GameColors.textDark,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            widget.mission.title.toUpperCase(),
            style: const TextStyle(
              color: GameColors.text,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _getDifficultyColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _getDifficultyColor()),
          ),
          child: Text(
            widget.mission.getDifficultyLabel(),
            style: TextStyle(
              color: _getDifficultyColor(),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMissionInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GameColors.backgroundLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GameColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: GameColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.mission.location,
                  style: const TextStyle(
                    color: GameColors.text,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.mission.storyText,
            style: const TextStyle(
              color: GameColors.textDark,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRewardInfo(
                Icons.monetization_on,
                '${widget.mission.rewardCoins}',
                GameColors.coin,
              ),
              _buildRewardInfo(
                Icons.star,
                '${widget.mission.rewardStars}',
                GameColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardInfo(IconData icon, String value, Color color) {
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

  Widget _buildObjectives() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameColors.backgroundLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GameColors.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OBJECTIVES',
            style: TextStyle(
              color: GameColors.accent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.mission.objectives.map((obj) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: GameColors.textDark,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        obj.description,
                        style: const TextStyle(
                          color: GameColors.text,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDialogue() {
    return AnimatedBuilder(
      animation: _fadeAnim,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: GameColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GameColors.primary.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: GameColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: GameColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _getSpeakerName(),
                  style: const TextStyle(
                    color: GameColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _getCurrentDialogue(),
              style: const TextStyle(
                color: GameColors.text,
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_currentDialogueIndex + 1}/${widget.mission.dialogue.length}',
                style: const TextStyle(
                  color: GameColors.textDark,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSpeakerName() {
    final dialogue = widget.mission.dialogue[_currentDialogueIndex];
    if (dialogue.contains(':')) {
      return dialogue.split(':')[0];
    }
    return 'Command';
  }

  String _getCurrentDialogue() {
    final dialogue = widget.mission.dialogue[_currentDialogueIndex];
    if (dialogue.contains(':')) {
      return dialogue.split(':').sublist(1).join(':').trim();
    }
    return dialogue;
  }

  Widget _buildContinueButton() {
    final isLastDialogue =
        _currentDialogueIndex >= widget.mission.dialogue.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _nextDialogue,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GameColors.primary,
                  GameColors.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: GameColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLastDialogue ? 'START MISSION' : 'CONTINUE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isLastDialogue ? Icons.play_arrow : Icons.arrow_forward,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
