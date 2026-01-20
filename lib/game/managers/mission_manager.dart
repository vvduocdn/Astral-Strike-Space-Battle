import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/mission.dart';
import '../../utils/constants.dart';

class MissionManager {
  static final MissionManager _instance = MissionManager._internal();
  factory MissionManager() => _instance;
  MissionManager._internal();

  Map<int, MissionProgress> _missionProgress = {};
  Mission? _currentMission;

  // Combat stats for mission tracking
  int _enemiesKilledInMission = 0;
  int _coinsCollectedInMission = 0;
  int _comboCount = 0;
  int _maxCombo = 0;
  double _survivalTime = 0;
  int _damageTaken = 0;
  int _initialHealth = 100;
  bool _bossDefeatedInMission = false;

  Mission? get currentMission => _currentMission;
  Map<int, MissionProgress> get missionProgress => _missionProgress;

  /// Start a mission
  void startMission(Mission mission) {
    _currentMission = mission;
    _resetMissionStats();
  }

  /// Reset mission statistics
  void _resetMissionStats() {
    _enemiesKilledInMission = 0;
    _coinsCollectedInMission = 0;
    _comboCount = 0;
    _maxCombo = 0;
    _survivalTime = 0;
    _damageTaken = 0;
    _bossDefeatedInMission = false;
  }

  /// Update mission progress (called every frame)
  void update(double dt, {int? currentHealth, int? maxHealth}) {
    if (_currentMission == null) return;

    _survivalTime += dt;

    // Update objectives
    for (var objective in _currentMission!.objectives) {
      switch (objective.type) {
        case MissionType.survival:
          objective.updateProgress(_survivalTime.toInt());
          break;
        case MissionType.killCount:
          objective.updateProgress(_enemiesKilledInMission);
          break;
        case MissionType.collectCoins:
          objective.updateProgress(_coinsCollectedInMission);
          break;
        case MissionType.comboMaster:
          objective.updateProgress(_maxCombo);
          break;
        case MissionType.bossKill:
          objective.updateProgress(_bossDefeatedInMission ? 1 : 0);
          break;
        case MissionType.noHit:
          objective.updateProgress(_damageTaken == 0 ? 1 : 0);
          break;
        case MissionType.timeAttack:
          // Will be checked on completion
          break;
        case MissionType.protect:
          // Check health percentage
          if (currentHealth != null && maxHealth != null && maxHealth > 0) {
            final healthPercent = (currentHealth / maxHealth * 100).toInt();
            // If health is above target, mark as complete
            if (healthPercent >= objective.targetValue) {
              objective.updateProgress(objective.targetValue);
            } else {
              objective.updateProgress(healthPercent);
            }
          }
          break;
        case MissionType.specificEnemy:
        case MissionType.escort:
          // Custom tracking needed
          break;
      }
    }
  }

  /// Called when enemy is killed
  void onEnemyKilled(EnemyType? enemyType) {
    _enemiesKilledInMission++;
    _comboCount++;
    if (_comboCount > _maxCombo) {
      _maxCombo = _comboCount;
    }
  }

  /// Called when coin is collected
  void onCoinCollected(int amount) {
    _coinsCollectedInMission += amount;
  }

  /// Called when player takes damage
  void onDamageTaken(int damage) {
    _damageTaken += damage;
    _comboCount = 0; // Reset combo on hit
  }

  /// Called when boss is defeated
  void onBossDefeated() {
    _bossDefeatedInMission = true;
  }

  /// Check if mission is complete
  bool isMissionComplete() {
    if (_currentMission == null) return false;

    // Check time limit
    if (_currentMission!.timeLimit != null) {
      if (_survivalTime > _currentMission!.timeLimit!) {
        return false; // Failed time limit
      }
    }

    // Check all objectives
    return _currentMission!.isCompleted;
  }

  /// Complete current mission
  void completeMission(int finalScore, int currentHealth) {
    if (_currentMission == null) return;

    // Calculate stars earned (1-3)
    int stars = 1;

    // Star 2: Complete all objectives
    if (_currentMission!.isCompleted) {
      stars = 2;
    }

    // Star 3: Additional challenges
    bool bonus = false;
    if (_currentMission!.noHitRequired == true && _damageTaken == 0) {
      bonus = true;
    } else if (_currentMission!.timeLimit != null &&
        _survivalTime <= _currentMission!.timeLimit! * 0.7) {
      bonus = true;
    } else if (currentHealth >= _initialHealth * 0.8) {
      bonus = true;
    }

    if (bonus && stars == 2) {
      stars = 3;
    }

    // Save progress
    final progress = MissionProgress(
      missionId: _currentMission!.id,
      completed: true,
      starsEarned: stars,
      bestScore: finalScore,
      completedAt: DateTime.now(),
    );

    _missionProgress[_currentMission!.id] = progress;
    save();
  }

  /// Get mission by ID
  Mission? getMissionById(int id) {
    return getAllMissions().firstWhere(
      (m) => m.id == id,
      orElse: () => getAllMissions().first,
    );
  }

  /// Get progress for a mission
  MissionProgress? getProgressForMission(int missionId) {
    return _missionProgress[missionId];
  }

  /// Check if mission is unlocked
  bool isMissionUnlocked(int missionId) {
    if (missionId == 1) return true; // First mission always unlocked

    // Unlock if previous mission is completed
    final previousProgress = _missionProgress[missionId - 1];
    return previousProgress?.completed ?? false;
  }

  /// Save progress to storage
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = _missionProgress.map(
      (key, value) => MapEntry(key.toString(), value.toJson()),
    );
    await prefs.setString('missionProgress', json.encode(progressJson));
  }

  /// Load progress from storage
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('missionProgress');

    if (jsonStr != null) {
      final Map<String, dynamic> decoded = json.decode(jsonStr);
      _missionProgress = decoded.map(
        (key, value) => MapEntry(
          int.parse(key),
          MissionProgress.fromJson(value),
        ),
      );
    }
  }

  /// Get all missions (will be populated with 40 missions)
  List<Mission> getAllMissions() {
    return _allMissions;
  }

  /// Get missions by difficulty
  List<Mission> getMissionsByDifficulty(MissionDifficulty difficulty) {
    return getAllMissions().where((m) => m.difficulty == difficulty).toList();
  }

  /// Get completed missions count
  int getCompletedMissionsCount() {
    return _missionProgress.values.where((p) => p.completed).length;
  }

  /// Get total stars earned
  int getTotalStarsEarned() {
    return _missionProgress.values
        .fold(0, (sum, progress) => sum + progress.starsEarned);
  }
}

// ============================================================================
// MISSION DATA - 40 UNIQUE MISSIONS
// ============================================================================

final List<Mission> _allMissions = [
  // CHAPTER 1: BASIC TRAINING (Missions 1-5) - EASY
  Mission(
    id: 1,
    title: 'First Flight',
    storyText: 'Welcome to the Astral Strike division, pilot. Your first mission is simple: survive the initial wave and prove your worth.',
    location: 'Training Sector Alpha',
    difficulty: MissionDifficulty.easy,
    objectives: [
      MissionObjective(
        type: MissionType.survival,
        targetValue: 30,
        description: 'Survive for 30 seconds',
      ),
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 5,
        description: 'Destroy 5 enemy ships',
      ),
    ],
    rewardCoins: 50,
    rewardStars: 3,
    dialogue: [
      'Commander: Welcome aboard, pilot!',
      'This is your first training mission.',
      'Show us what you\'ve got!',
    ],
    completionDialogue: 'Excellent work! You\'re ready for more.',
  ),

  Mission(
    id: 2,
    title: 'Target Practice',
    storyText: 'The shooting range is yours. Demonstrate your accuracy by eliminating all targets.',
    location: 'Training Sector Beta',
    difficulty: MissionDifficulty.easy,
    objectives: [
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 15,
        description: 'Destroy 15 enemies',
      ),
    ],
    rewardCoins: 75,
    rewardStars: 3,
    dialogue: [
      'Instructor: Time to test your aim.',
      'Take down all targets efficiently.',
      'Remember: precision over speed!',
    ],
  ),

  Mission(
    id: 3,
    title: 'Defensive Maneuvers',
    storyText: 'Survival isn\'t just about firepower. Prove you can evade enemy attacks.',
    location: 'Training Sector Gamma',
    difficulty: MissionDifficulty.easy,
    objectives: [
      MissionObjective(
        type: MissionType.survival,
        targetValue: 45,
        description: 'Survive for 45 seconds',
      ),
      MissionObjective(
        type: MissionType.protect,
        targetValue: 70,
        description: 'Keep health above 70%',
      ),
    ],
    rewardCoins: 100,
    rewardStars: 3,
    minHealth: 70,
    dialogue: [
      'Instructor: Defense is key to survival.',
      'Dodge incoming fire and survive.',
      'Your shields won\'t save you forever!',
    ],
  ),

  Mission(
    id: 4,
    title: 'Resource Collection',
    storyText: 'In war, resources are everything. Collect coins from destroyed enemies.',
    location: 'Asteroid Belt Minor',
    difficulty: MissionDifficulty.easy,
    objectives: [
      MissionObjective(
        type: MissionType.collectCoins,
        targetValue: 50,
        description: 'Collect 50 coins',
      ),
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 10,
        description: 'Destroy 10 enemies',
      ),
    ],
    rewardCoins: 125,
    rewardStars: 3,
    dialogue: [
      'Commander: We need resources, pilot.',
      'Salvage what you can from the wreckage.',
      'Every coin counts!',
    ],
  ),

  Mission(
    id: 5,
    title: 'Graduation Day',
    storyText: 'Your final training mission. Complete it flawlessly to join the main fleet.',
    location: 'Training Sector Final',
    difficulty: MissionDifficulty.easy,
    objectives: [
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 20,
        description: 'Destroy 20 enemies',
      ),
      MissionObjective(
        type: MissionType.noHit,
        targetValue: 1,
        description: 'Take no damage',
      ),
    ],
    rewardCoins: 200,
    rewardStars: 3,
    noHitRequired: true,
    dialogue: [
      'Commander: This is it, pilot.',
      'Complete this perfectly and you\'re in.',
      'No mistakes allowed!',
    ],
    completionDialogue: 'Outstanding! Welcome to the Astral Strike force!',
  ),

  // CHAPTER 2: FIRST ENCOUNTERS (Missions 6-12) - EASY/MEDIUM
  Mission(
    id: 6,
    title: 'Pirate Ambush',
    storyText: 'Space pirates have been spotted near a trade route. Clear them out.',
    location: 'Trade Route Zeta',
    difficulty: MissionDifficulty.easy,
    objectives: [
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 25,
        description: 'Destroy 25 pirate ships',
      ),
    ],
    rewardCoins: 150,
    rewardStars: 3,
    dialogue: [
      'Fleet Command: Pirates in the area!',
      'They\'re threatening our supply lines.',
      'Eliminate the threat!',
    ],
    hasSpaceEvents: true,
    allowedEvents: ['debris'],
  ),

  Mission(
    id: 7,
    title: 'Asteroid Navigation',
    storyText: 'Navigate through a dense asteroid field while fighting off enemies.',
    location: 'Asteroid Belt Major',
    difficulty: MissionDifficulty.medium,
    objectives: [
      MissionObjective(
        type: MissionType.survival,
        targetValue: 60,
        description: 'Survive 60 seconds',
      ),
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 15,
        description: 'Destroy 15 enemies',
      ),
    ],
    rewardCoins: 200,
    rewardStars: 3,
    dialogue: [
      'Navigator: Dense asteroid field ahead!',
      'Watch out for both rocks and enemies.',
      'This won\'t be easy!',
    ],
    hasSpaceEvents: true,
    allowedEvents: ['asteroidField'],
  ),

  Mission(
    id: 8,
    title: 'Speed Run',
    storyText: 'Time is critical. Complete your objectives before reinforcements arrive.',
    location: 'Outer Rim Delta',
    difficulty: MissionDifficulty.medium,
    objectives: [
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 30,
        description: 'Destroy 30 enemies',
      ),
      MissionObjective(
        type: MissionType.timeAttack,
        targetValue: 90,
        description: 'Complete in 90 seconds',
      ),
    ],
    rewardCoins: 250,
    rewardStars: 3,
    timeLimit: 90,
    dialogue: [
      'Command: Enemy reinforcements inbound!',
      'Complete the mission quickly!',
      'You have 90 seconds!',
    ],
  ),

  Mission(
    id: 9,
    title: 'Combo Master',
    storyText: 'Intel reports enemy coordination is weak. Chain attacks for maximum efficiency.',
    location: 'Sector Kappa',
    difficulty: MissionDifficulty.medium,
    objectives: [
      MissionObjective(
        type: MissionType.comboMaster,
        targetValue: 10,
        description: 'Achieve 10-hit combo',
      ),
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 25,
        description: 'Destroy 25 enemies',
      ),
    ],
    rewardCoins: 225,
    rewardStars: 3,
    dialogue: [
      'Tactical: Their defenses are scattered.',
      'Chain your attacks together!',
      'Don\'t let up!',
    ],
  ),

  Mission(
    id: 10,
    title: 'Storm Warning',
    storyText: 'A solar storm is approaching. Fight through it while your shields are weakened.',
    location: 'Solar Zone Proxima',
    difficulty: MissionDifficulty.medium,
    objectives: [
      MissionObjective(
        type: MissionType.survival,
        targetValue: 75,
        description: 'Survive 75 seconds',
      ),
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 20,
        description: 'Destroy 20 enemies',
      ),
    ],
    rewardCoins: 275,
    rewardStars: 3,
    dialogue: [
      'Science Officer: Solar storm detected!',
      'Shields will be compromised!',
      'Proceed with extreme caution!',
    ],
    hasSpaceEvents: true,
    allowedEvents: ['solarStorm'],
  ),

  Mission(
    id: 11,
    title: 'Perfect Execution',
    storyText: 'A stealth mission requires flawless execution. No mistakes.',
    location: 'Shadow Sector',
    difficulty: MissionDifficulty.medium,
    objectives: [
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 20,
        description: 'Destroy 20 enemies',
      ),
      MissionObjective(
        type: MissionType.noHit,
        targetValue: 1,
        description: 'Take zero damage',
      ),
    ],
    rewardCoins: 300,
    rewardStars: 3,
    noHitRequired: true,
    dialogue: [
      'Intel: This is a stealth operation.',
      'We can\'t afford any alarms.',
      'Stay undetected!',
    ],
  ),

  Mission(
    id: 12,
    title: 'Supply Raid',
    storyText: 'Raid enemy supply convoys and secure maximum resources.',
    location: 'Supply Route Omega',
    difficulty: MissionDifficulty.medium,
    objectives: [
      MissionObjective(
        type: MissionType.collectCoins,
        targetValue: 100,
        description: 'Collect 100 coins',
      ),
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 25,
        description: 'Destroy 25 enemies',
      ),
    ],
    rewardCoins: 350,
    rewardStars: 3,
    dialogue: [
      'Commander: Enemy supply convoy spotted!',
      'Secure those resources!',
      'The fleet needs every coin!',
    ],
  ),

  // CHAPTER 3: RISING THREAT (Missions 13-20) - MEDIUM/HARD
  Mission(
    id: 13,
    title: 'First Boss: Pirate Lord',
    storyText: 'The pirate leader has appeared. This will be your first real challenge.',
    location: 'Pirate Haven',
    difficulty: MissionDifficulty.medium,
    objectives: [
      MissionObjective(
        type: MissionType.bossKill,
        targetValue: 1,
        description: 'Defeat the Pirate Lord',
      ),
    ],
    rewardCoins: 500,
    rewardStars: 3,
    dialogue: [
      'Intel: The Pirate Lord has entered the sector!',
      'This is their strongest ship!',
      'Be prepared for anything!',
    ],
    completionDialogue: 'Incredible! You\'ve defeated the Pirate Lord!',
  ),

  Mission(
    id: 14,
    title: 'Black Hole Escape',
    storyText: 'You\'ve been pulled near a black hole. Fight your way out against its gravity.',
    location: 'Event Horizon Sector',
    difficulty: MissionDifficulty.hard,
    objectives: [
      MissionObjective(
        type: MissionType.survival,
        targetValue: 60,
        description: 'Survive 60 seconds',
      ),
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 20,
        description: 'Destroy 20 enemies',
      ),
    ],
    rewardCoins: 400,
    rewardStars: 3,
    dialogue: [
      'Science: Gravitational anomaly detected!',
      'It\'s a black hole!',
      'Fight the pull and escape!',
    ],
    hasSpaceEvents: true,
    allowedEvents: ['blackHole'],
  ),

  Mission(
    id: 15,
    title: 'Nebula Run',
    storyText: 'Navigate through a dense nebula cloud with reduced visibility.',
    location: 'Crimson Nebula',
    difficulty: MissionDifficulty.medium,
    objectives: [
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 30,
        description: 'Destroy 30 enemies',
      ),
      MissionObjective(
        type: MissionType.protect,
        targetValue: 60,
        description: 'Keep health above 60%',
      ),
    ],
    rewardCoins: 350,
    rewardStars: 3,
    dialogue: [
      'Navigator: Entering nebula cloud!',
      'Visibility is near zero!',
      'Trust your instruments!',
    ],
    hasSpaceEvents: true,
    allowedEvents: ['nebula'],
  ),

  Mission(
    id: 16,
    title: 'Wormhole Chaos',
    storyText: 'Space-time distortions are causing random teleportation. Adapt quickly!',
    location: 'Wormhole Junction',
    difficulty: MissionDifficulty.hard,
    objectives: [
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 35,
        description: 'Destroy 35 enemies',
      ),
      MissionObjective(
        type: MissionType.survival,
        targetValue: 90,
        description: 'Survive 90 seconds',
      ),
    ],
    rewardCoins: 450,
    rewardStars: 3,
    dialogue: [
      'Science: Wormhole activity detected!',
      'Your position may shift randomly!',
      'Stay alert!',
    ],
    hasSpaceEvents: true,
    allowedEvents: ['wormhole'],
  ),

  Mission(
    id: 17,
    title: 'Radiation Zone',
    storyText: 'You must pass through a radioactive zone. Your hull will take constant damage.',
    location: 'Irradiated Sector 7',
    difficulty: MissionDifficulty.hard,
    objectives: [
      MissionObjective(
        type: MissionType.survival,
        targetValue: 60,
        description: 'Survive 60 seconds',
      ),
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 25,
        description: 'Destroy 25 enemies',
      ),
    ],
    rewardCoins: 425,
    rewardStars: 3,
    dialogue: [
      'Medical: Radiation levels critical!',
      'Your hull will take constant damage!',
      'Get through this quickly!',
    ],
    hasSpaceEvents: true,
    allowedEvents: ['radiationZone'],
  ),

  Mission(
    id: 18,
    title: 'Magnetic Anomaly',
    storyText: 'A magnetic field is interfering with your weapons systems.',
    location: 'Magnetic Zone Beta',
    difficulty: MissionDifficulty.hard,
    objectives: [
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 40,
        description: 'Destroy 40 enemies',
      ),
    ],
    rewardCoins: 400,
    rewardStars: 3,
    dialogue: [
      'Engineer: Magnetic interference detected!',
      'Weapon systems compromised!',
      'Compensate for the distortion!',
    ],
    hasSpaceEvents: true,
    allowedEvents: ['magneticField'],
  ),

  Mission(
    id: 19,
    title: 'Marathon Battle',
    storyText: 'A prolonged engagement awaits. Prove your endurance.',
    location: 'Frontier Zone',
    difficulty: MissionDifficulty.hard,
    objectives: [
      MissionObjective(
        type: MissionType.survival,
        targetValue: 120,
        description: 'Survive 120 seconds',
      ),
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 50,
        description: 'Destroy 50 enemies',
      ),
    ],
    rewardCoins: 550,
    rewardStars: 3,
    dialogue: [
      'Command: This will be a long fight.',
      'Pace yourself, pilot.',
      'Victory through endurance!',
    ],
  ),

  Mission(
    id: 20,
    title: 'Elite Squadron',
    storyText: 'Face off against an elite enemy squadron. They won\'t go down easily.',
    location: 'Combat Zone Elite',
    difficulty: MissionDifficulty.hard,
    objectives: [
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 30,
        description: 'Destroy 30 elite enemies',
      ),
      MissionObjective(
        type: MissionType.comboMaster,
        targetValue: 15,
        description: 'Achieve 15-hit combo',
      ),
    ],
    rewardCoins: 500,
    rewardStars: 3,
    dialogue: [
      'Intel: Enemy elites inbound!',
      'These aren\'t regular troops!',
      'Give them everything you\'ve got!',
    ],
  ),

  // CHAPTER 4: CRITICAL MISSIONS (Missions 21-30) - HARD/EXPERT
  Mission(
    id: 21,
    title: 'Boss: Destroyer Class',
    storyText: 'A massive destroyer-class warship blocks your path.',
    location: 'War Zone Alpha',
    difficulty: MissionDifficulty.hard,
    objectives: [
      MissionObjective(
        type: MissionType.bossKill,
        targetValue: 1,
        description: 'Defeat the Destroyer',
      ),
    ],
    rewardCoins: 700,
    rewardStars: 3,
    dialogue: [
      'Fleet: Destroyer-class detected!',
      'This is their capital ship!',
      'All weapons free!',
    ],
  ),

  Mission(
    id: 22,
    title: 'Speedster Challenge',
    storyText: 'Face an onslaught of fast-moving enemies. Can you keep up?',
    location: 'Speed Zone',
    difficulty: MissionDifficulty.hard,
    objectives: [
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 45,
        description: 'Destroy 45 fast enemies',
      ),
      MissionObjective(
        type: MissionType.timeAttack,
        targetValue: 75,
        description: 'Complete in 75 seconds',
      ),
    ],
    rewardCoins: 550,
    rewardStars: 3,
    timeLimit: 75,
    dialogue: [
      'Tactical: Enemy speedsters incoming!',
      'They\'re incredibly fast!',
      'Don\'t let them escape!',
    ],
  ),

  Mission(
    id: 23,
    title: 'Tank Busters',
    storyText: 'Heavy armored enemies require sustained fire to destroy.',
    location: 'Armor Testing Ground',
    difficulty: MissionDifficulty.hard,
    objectives: [
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 20,
        description: 'Destroy 20 tank enemies',
      ),
    ],
    rewardCoins: 525,
    rewardStars: 3,
    dialogue: [
      'Intel: Heavy armor detected!',
      'These will take sustained fire!',
      'Concentrate your attacks!',
    ],
  ),

  Mission(
    id: 24,
    title: 'Multi-Hazard Zone',
    storyText: 'Multiple space hazards converge in this sector. Extreme danger!',
    location: 'Chaos Sector',
    difficulty: MissionDifficulty.expert,
    objectives: [
      MissionObjective(
        type: MissionType.survival,
        targetValue: 90,
        description: 'Survive 90 seconds',
      ),
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 35,
        description: 'Destroy 35 enemies',
      ),
    ],
    rewardCoins: 650,
    rewardStars: 3,
    dialogue: [
      'Science: Multiple hazards detected!',
      'This sector is extremely dangerous!',
      'Only our best can survive this!',
    ],
    hasSpaceEvents: true,
  ),

  Mission(
    id: 25,
    title: 'Flawless Victory',
    storyText: 'A crucial mission that demands perfection. No room for error.',
    location: 'Critical Point',
    difficulty: MissionDifficulty.expert,
    objectives: [
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 40,
        description: 'Destroy 40 enemies',
      ),
      MissionObjective(
        type: MissionType.noHit,
        targetValue: 1,
        description: 'Take zero damage',
      ),
    ],
    rewardCoins: 800,
    rewardStars: 3,
    noHitRequired: true,
    dialogue: [
      'Command: This mission is crucial!',
      'We need flawless execution!',
      'The entire operation depends on you!',
    ],
  ),

  Mission(
    id: 26,
    title: 'Coin Rush Extreme',
    storyText: 'A wealthy convoy passes through. Maximize your salvage!',
    location: 'Treasure Route',
    difficulty: MissionDifficulty.hard,
    objectives: [
      MissionObjective(
        type: MissionType.collectCoins,
        targetValue: 200,
        description: 'Collect 200 coins',
      ),
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 40,
        description: 'Destroy 40 enemies',
      ),
    ],
    rewardCoins: 750,
    rewardStars: 3,
    dialogue: [
      'Intel: High-value targets detected!',
      'Secure maximum resources!',
      'This opportunity won\'t come again!',
    ],
  ),

  Mission(
    id: 27,
    title: 'Combo Legend',
    storyText: 'Achieve the highest combo ever recorded in combat.',
    location: 'Combat Arena',
    difficulty: MissionDifficulty.expert,
    objectives: [
      MissionObjective(
        type: MissionType.comboMaster,
        targetValue: 25,
        description: 'Achieve 25-hit combo',
      ),
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 50,
        description: 'Destroy 50 enemies',
      ),
    ],
    rewardCoins: 700,
    rewardStars: 3,
    dialogue: [
      'Tactical: Time to set a new record!',
      'Chain attacks without stopping!',
      'Become a legend!',
    ],
  ),

  Mission(
    id: 28,
    title: 'Survival Mastery',
    storyText: 'The ultimate endurance test. Can you last long enough?',
    location: 'Endurance Zone',
    difficulty: MissionDifficulty.expert,
    objectives: [
      MissionObjective(
        type: MissionType.survival,
        targetValue: 180,
        description: 'Survive 180 seconds',
      ),
      MissionObjective(
        type: MissionType.protect,
        targetValue: 50,
        description: 'Keep health above 50%',
      ),
    ],
    rewardCoins: 850,
    rewardStars: 3,
    dialogue: [
      'Command: The ultimate survival test.',
      '3 minutes of pure combat.',
      'Show us your mastery!',
    ],
  ),

  Mission(
    id: 29,
    title: 'All Hazards Active',
    storyText: 'Every known space hazard is present. Only the elite survive.',
    location: 'Hell Sector',
    difficulty: MissionDifficulty.expert,
    objectives: [
      MissionObjective(
        type: MissionType.survival,
        targetValue: 120,
        description: 'Survive 120 seconds',
      ),
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 45,
        description: 'Destroy 45 enemies',
      ),
      MissionObjective(
        type: MissionType.protect,
        targetValue: 40,
        description: 'Keep health above 40%',
      ),
    ],
    rewardCoins: 1000,
    rewardStars: 3,
    dialogue: [
      'Science: All hazard systems active!',
      'This is the most dangerous sector known!',
      'Only attempt if you\'re ready!',
    ],
    hasSpaceEvents: true,
  ),

  Mission(
    id: 30,
    title: 'Boss: Battle Cruiser',
    storyText: 'Their most powerful ship has arrived. This is it, pilot.',
    location: 'Final Stand',
    difficulty: MissionDifficulty.expert,
    objectives: [
      MissionObjective(
        type: MissionType.bossKill,
        targetValue: 1,
        description: 'Defeat the Battle Cruiser',
      ),
    ],
    rewardCoins: 1200,
    rewardStars: 3,
    dialogue: [
      'Fleet Command: Battle Cruiser detected!',
      'This is their ultimate weapon!',
      'Everything depends on you now!',
    ],
    completionDialogue: 'INCREDIBLE! You\'ve saved the entire fleet!',
  ),

  // CHAPTER 5: LEGENDARY CHALLENGES (Missions 31-40) - EXPERT
  Mission(
    id: 31,
    title: 'Speed Demon',
    storyText: 'An impossible time limit. Only the fastest pilots can succeed.',
    location: 'Time Trial Zone',
    difficulty: MissionDifficulty.expert,
    objectives: [
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 50,
        description: 'Destroy 50 enemies',
      ),
      MissionObjective(
        type: MissionType.timeAttack,
        targetValue: 60,
        description: 'Complete in 60 seconds',
      ),
    ],
    rewardCoins: 900,
    rewardStars: 3,
    timeLimit: 60,
    dialogue: [
      'Command: We need speed, pilot!',
      'One minute to complete the mission!',
      'Show us your fastest work!',
    ],
  ),

  Mission(
    id: 32,
    title: 'Perfect Storm',
    storyText: 'Battle through the most intense solar storm ever recorded.',
    location: 'Storm Omega',
    difficulty: MissionDifficulty.expert,
    objectives: [
      MissionObjective(
        type: MissionType.survival,
        targetValue: 90,
        description: 'Survive 90 seconds',
      ),
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 40,
        description: 'Destroy 40 enemies',
      ),
      MissionObjective(
        type: MissionType.noHit,
        targetValue: 1,
        description: 'Take no damage from enemies',
      ),
    ],
    rewardCoins: 950,
    rewardStars: 3,
    hasSpaceEvents: true,
    allowedEvents: ['solarStorm'],
    dialogue: [
      'Science: Storm intensity at maximum!',
      'This has never been attempted before!',
      'Good luck, pilot!',
    ],
  ),

  Mission(
    id: 33,
    title: 'Black Hole Master',
    storyText: 'Use the black hole\'s gravity to your advantage in battle.',
    location: 'Singularity Prime',
    difficulty: MissionDifficulty.expert,
    objectives: [
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 50,
        description: 'Destroy 50 enemies',
      ),
      MissionObjective(
        type: MissionType.comboMaster,
        targetValue: 20,
        description: 'Achieve 20-hit combo',
      ),
    ],
    rewardCoins: 925,
    rewardStars: 3,
    hasSpaceEvents: true,
    allowedEvents: ['blackHole'],
    dialogue: [
      'Science: The black hole can work for you!',
      'Master its pull and dominate!',
      'Physics is your weapon!',
    ],
  ),

  Mission(
    id: 34,
    title: 'Treasure Hunter',
    storyText: 'A legendary treasure field awaits. Claim it all!',
    location: 'Treasure Nebula',
    difficulty: MissionDifficulty.expert,
    objectives: [
      MissionObjective(
        type: MissionType.collectCoins,
        targetValue: 300,
        description: 'Collect 300 coins',
      ),
      MissionObjective(
        type: MissionType.survival,
        targetValue: 120,
        description: 'Survive 120 seconds',
      ),
    ],
    rewardCoins: 1100,
    rewardStars: 3,
    dialogue: [
      'Intel: Massive resource field detected!',
      'This could fund the entire fleet!',
      'Secure everything!',
    ],
  ),

  Mission(
    id: 35,
    title: 'Asteroid Hell',
    storyText: 'The densest asteroid field ever encountered. Survive if you can.',
    location: 'Asteroid Graveyard',
    difficulty: MissionDifficulty.expert,
    objectives: [
      MissionObjective(
        type: MissionType.survival,
        targetValue: 150,
        description: 'Survive 150 seconds',
      ),
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 35,
        description: 'Destroy 35 enemies',
      ),
      MissionObjective(
        type: MissionType.protect,
        targetValue: 60,
        description: 'Keep health above 60%',
      ),
    ],
    rewardCoins: 975,
    rewardStars: 3,
    hasSpaceEvents: true,
    allowedEvents: ['asteroidField', 'debris'],
    dialogue: [
      'Navigator: Asteroid density at critical levels!',
      'This field has claimed countless ships!',
      'Navigate with extreme caution!',
    ],
  ),

  Mission(
    id: 36,
    title: 'Boss Rush',
    storyText: 'Multiple enemy commanders have gathered. Defeat them all!',
    location: 'Command Nexus',
    difficulty: MissionDifficulty.expert,
    objectives: [
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 60,
        description: 'Destroy 60 elite enemies',
      ),
      MissionObjective(
        type: MissionType.survival,
        targetValue: 150,
        description: 'Survive 150 seconds',
      ),
    ],
    rewardCoins: 1150,
    rewardStars: 3,
    dialogue: [
      'Intel: Multiple commanders detected!',
      'They\'ve gathered their forces!',
      'This is their last stand!',
    ],
  ),

  Mission(
    id: 37,
    title: 'Untouchable',
    storyText: 'Complete an extended mission without taking a single hit.',
    location: 'Perfection Zone',
    difficulty: MissionDifficulty.expert,
    objectives: [
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 55,
        description: 'Destroy 55 enemies',
      ),
      MissionObjective(
        type: MissionType.survival,
        targetValue: 120,
        description: 'Survive 120 seconds',
      ),
      MissionObjective(
        type: MissionType.noHit,
        targetValue: 1,
        description: 'Take zero damage',
      ),
    ],
    rewardCoins: 1300,
    rewardStars: 3,
    noHitRequired: true,
    dialogue: [
      'Command: We need perfection, pilot.',
      'Not a single hit allowed.',
      'Can you achieve the impossible?',
    ],
  ),

  Mission(
    id: 38,
    title: 'Ultimate Combo',
    storyText: 'Set the all-time combat combo record.',
    location: 'Record Chamber',
    difficulty: MissionDifficulty.expert,
    objectives: [
      MissionObjective(
        type: MissionType.comboMaster,
        targetValue: 35,
        description: 'Achieve 35-hit combo',
      ),
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 70,
        description: 'Destroy 70 enemies',
      ),
    ],
    rewardCoins: 1250,
    rewardStars: 3,
    dialogue: [
      'Tactical: Time for the ultimate record!',
      '35-hit combo has never been done!',
      'Make history, pilot!',
    ],
  ),

  Mission(
    id: 39,
    title: 'Chaos Incarnate',
    storyText: 'All hazards, maximum enemies, limited time. The ultimate test.',
    location: 'Chaos Prime',
    difficulty: MissionDifficulty.expert,
    objectives: [
      MissionObjective(
        type: MissionType.survival,
        targetValue: 180,
        description: 'Survive 180 seconds',
      ),
      MissionObjective(
        type: MissionType.killCount,
        targetValue: 80,
        description: 'Destroy 80 enemies',
      ),
      MissionObjective(
        type: MissionType.comboMaster,
        targetValue: 30,
        description: 'Achieve 30-hit combo',
      ),
      MissionObjective(
        type: MissionType.collectCoins,
        targetValue: 150,
        description: 'Collect 150 coins',
      ),
    ],
    rewardCoins: 1500,
    rewardStars: 3,
    hasSpaceEvents: true,
    dialogue: [
      'Command: This is it, pilot.',
      'Every system at maximum difficulty.',
      'Only legends can complete this!',
    ],
  ),

  Mission(
    id: 40,
    title: 'FINAL BOSS: Mothership',
    storyText: 'The enemy Mothership has arrived. The fate of the galaxy rests on your shoulders.',
    location: 'Final Battlefield',
    difficulty: MissionDifficulty.expert,
    objectives: [
      MissionObjective(
        type: MissionType.bossKill,
        targetValue: 1,
        description: 'Defeat the Mothership',
      ),
      MissionObjective(
        type: MissionType.survival,
        targetValue: 200,
        description: 'Survive the encounter',
      ),
    ],
    rewardCoins: 2000,
    rewardStars: 3,
    dialogue: [
      'Fleet Command: The Mothership has arrived!',
      'This is the final battle!',
      'The entire galaxy is counting on you!',
      'Give it everything you\'ve got, pilot!',
    ],
    completionDialogue:
        'LEGENDARY! You\'ve defeated the Mothership and saved the galaxy! You are a TRUE HERO!',
  ),
];
