/// Mission system for story mode
/// Different mission types with unique objectives

enum MissionType {
  survival, // Survive for X seconds
  killCount, // Kill X enemies
  bossKill, // Defeat the boss
  noHit, // Complete without taking damage
  timeAttack, // Complete within time limit
  protect, // Keep health above X%
  collectCoins, // Collect X coins
  comboMaster, // Achieve X combo
  specificEnemy, // Kill X of specific enemy type
  escort, // Protect allied ship
}

enum MissionDifficulty {
  easy,
  medium,
  hard,
  expert,
}

class MissionObjective {
  final MissionType type;
  final int targetValue;
  final String description;
  int currentValue;

  MissionObjective({
    required this.type,
    required this.targetValue,
    required this.description,
    this.currentValue = 0,
  });

  bool get isCompleted => currentValue >= targetValue;
  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);

  void updateProgress(int value) {
    currentValue = value;
  }

  void incrementProgress([int amount = 1]) {
    currentValue += amount;
  }
}

class Mission {
  final int id;
  final String title;
  final String storyText;
  final String location;
  final MissionDifficulty difficulty;
  final List<MissionObjective> objectives;
  final int rewardCoins;
  final int rewardStars;
  final List<String> dialogue; // Pre-mission dialogue
  final String? completionDialogue;
  final bool hasSpaceEvents; // Whether this mission has space hazards
  final List<String>? allowedEvents; // Specific events for this mission

  // Optional constraints
  final int? timeLimit; // seconds
  final int? minHealth; // minimum health to maintain
  final bool? noHitRequired;

  Mission({
    required this.id,
    required this.title,
    required this.storyText,
    required this.location,
    required this.difficulty,
    required this.objectives,
    required this.rewardCoins,
    required this.rewardStars,
    required this.dialogue,
    this.completionDialogue,
    this.hasSpaceEvents = false,
    this.allowedEvents,
    this.timeLimit,
    this.minHealth,
    this.noHitRequired,
  });

  bool get isCompleted => objectives.every((obj) => obj.isCompleted);

  double get overallProgress {
    if (objectives.isEmpty) return 0.0;
    return objectives.map((obj) => obj.progress).reduce((a, b) => a + b) /
           objectives.length;
  }

  String getDifficultyLabel() {
    switch (difficulty) {
      case MissionDifficulty.easy:
        return 'EASY';
      case MissionDifficulty.medium:
        return 'MEDIUM';
      case MissionDifficulty.hard:
        return 'HARD';
      case MissionDifficulty.expert:
        return 'EXPERT';
    }
  }
}

class MissionProgress {
  final int missionId;
  final bool completed;
  final int starsEarned;
  final int bestScore;
  final DateTime? completedAt;

  MissionProgress({
    required this.missionId,
    this.completed = false,
    this.starsEarned = 0,
    this.bestScore = 0,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'missionId': missionId,
        'completed': completed,
        'starsEarned': starsEarned,
        'bestScore': bestScore,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory MissionProgress.fromJson(Map<String, dynamic> json) {
    return MissionProgress(
      missionId: json['missionId'],
      completed: json['completed'] ?? false,
      starsEarned: json['starsEarned'] ?? 0,
      bestScore: json['bestScore'] ?? 0,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}
