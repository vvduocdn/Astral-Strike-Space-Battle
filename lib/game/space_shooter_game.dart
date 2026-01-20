import 'dart:async';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/player_data.dart';
import '../models/mission.dart';
import 'components/animated_player.dart';
import 'components/parallax_background.dart';
import 'components/animated_enemy.dart';
import 'components/bullet.dart';
import 'components/power_up.dart';
import 'components/animated_explosion.dart';
import 'components/explosion.dart';
import 'components/boss.dart';
import 'managers/spawn_manager.dart';
import 'managers/score_manager.dart';
import 'managers/audio_manager.dart';
import 'managers/mission_manager.dart';
import 'managers/space_event_manager.dart';

class SpaceShooterGame extends FlameGame
    with HasCollisionDetection, DragCallbacks, TapCallbacks {
  late AnimatedPlayer player;
  late SpawnManager spawnManager;
  late ScoreManager scoreManager;
  late ParallaxBackground background;

  // Mission system
  MissionManager? missionManager;
  SpaceEventManager? spaceEventManager;
  final Mission? mission;
  bool isMissionMode = false;
  bool _missionCompleted = false; // Track if mission already completed

  PlayerData playerData;
  GameState gameState = GameState.playing;

  int currentLevel = 1;
  int enemiesKilledThisLevel = 0;
  int enemiesRequiredForLevel = 10;
  bool isBossLevel = false;
  bool bossSpawned = false;
  double _levelStartDelay = 2.0; // Delay before checking level completion

  double _fireTimer = 0;
  bool _isFiring = false;

  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  final ValueNotifier<int> healthNotifier = ValueNotifier(100);
  final ValueNotifier<int> livesNotifier = ValueNotifier(3);
  final ValueNotifier<int> levelNotifier = ValueNotifier(1);
  final ValueNotifier<int> coinsNotifier = ValueNotifier(0);
  final ValueNotifier<int> bombNotifier = ValueNotifier(3);

  int bombCount = 3; // Start with 3 bombs

  VoidCallback? onGameOver;
  VoidCallback? onLevelComplete;
  VoidCallback? onPause;

  SpaceShooterGame({
    required this.playerData,
    this.mission,
  }) {
    isMissionMode = mission != null;
    if (isMissionMode) {
      missionManager = MissionManager();
      missionManager!.load();
      spaceEventManager = SpaceEventManager(game: this);
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set game size
    camera.viewfinder.visibleGameSize = Vector2(
      GameConstants.gameWidth,
      GameConstants.gameHeight,
    );
    camera.viewfinder.position = Vector2(
      GameConstants.gameWidth / 2,
      GameConstants.gameHeight / 2,
    );
    camera.viewfinder.anchor = Anchor.center;

    // Initialize audio
    await AudioManager().init();

    // Add background
    background = ParallaxBackground();
    world.add(background);

    // Add player
    player = AnimatedPlayer(
      position: Vector2(
        GameConstants.gameWidth / 2,
        GameConstants.gameHeight - 100,
      ),
      playerData: playerData,
    );
    world.add(player);

    // Initialize managers
    spawnManager = SpawnManager(game: this);
    scoreManager = ScoreManager();

    // Reset level progress
    enemiesKilledThisLevel = 0;

    // Update notifiers
    healthNotifier.value = player.health;
    livesNotifier.value = player.lives;
    levelNotifier.value = currentLevel;
    coinsNotifier.value = playerData.coins;

    // Calculate enemies required for this level
    _calculateLevelRequirements();

    // Start mission if in mission mode
    if (isMissionMode && mission != null) {
      missionManager!.startMission(mission!);

      // Enable space events if mission has them
      if (mission!.hasSpaceEvents) {
        spaceEventManager!.enableEvents(
          allowedEvents: mission!.allowedEvents,
        );
      }
    }

    // Start background music
    AudioManager().playBackgroundMusic();
  }

  void _calculateLevelRequirements() {
    // Ensure currentLevel is at least 1
    if (currentLevel < 1) currentLevel = 1;

    isBossLevel = currentLevel % GameConstants.bossEveryLevel == 0;
    if (isBossLevel) {
      enemiesRequiredForLevel = 5; // Less enemies before boss
    } else {
      enemiesRequiredForLevel = 10 + (currentLevel * 2);
    }
    bossSpawned = false;

    // Ensure minimum requirements
    if (enemiesRequiredForLevel < 5) enemiesRequiredForLevel = 5;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameState != GameState.playing) return;

    // Wait for level to start properly
    if (_levelStartDelay > 0) {
      _levelStartDelay -= dt;
      return;
    }

    // Update mission tracking
    if (isMissionMode && missionManager != null && !_missionCompleted) {
      missionManager!.update(
        dt,
        currentHealth: player.health,
        maxHealth: playerData.maxHealth,
      );

      // Check for mission completion (only once)
      if (missionManager!.isMissionComplete()) {
        _missionCompleted = true; // Mark as completed to prevent multiple triggers
        _completeMission();
        return;
      }
    }

    // Update space events
    if (spaceEventManager != null) {
      spaceEventManager!.update(dt);

      // Check collision with space hazards
      if (spaceEventManager!.checkAsteroidCollision(
        player.position,
        GameConstants.playerWidth / 2,
      )) {
        onPlayerHit(20); // Asteroid damage
      }

      if (spaceEventManager!.checkDebrisCollision(
        player.position,
        GameConstants.playerWidth / 2,
      )) {
        onPlayerHit(10); // Debris damage
      }
    }

    // Auto-fire
    if (_isFiring) {
      _fireTimer += dt;
      if (_fireTimer >= GameConstants.fireRate) {
        _fireTimer = 0;
        _shoot();
      }
    }

    // Spawn enemies
    spawnManager.update(dt);

    // Check level completion - only if player has actually killed enemies
    // (Skip in mission mode, as missions have their own completion logic)
    if (!isMissionMode &&
        enemiesKilledThisLevel > 0 &&
        enemiesKilledThisLevel >= enemiesRequiredForLevel) {
      if (isBossLevel && !bossSpawned) {
        _spawnBoss();
      } else if (!isBossLevel) {
        _completeLevel();
      }
    }
  }

  void _shoot() {
    final bullets = player.shoot();
    for (final bullet in bullets) {
      world.add(bullet);
    }
  }

  void _spawnBoss() {
    bossSpawned = true;
    gameState = GameState.bossWarning;
    AudioManager().playBossWarning();

    // Show boss warning for 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (gameState == GameState.bossWarning) {
        gameState = GameState.playing;
        final boss = Boss(
          position: Vector2(GameConstants.gameWidth / 2, -50),
          bossType: (currentLevel ~/ GameConstants.bossEveryLevel) - 1,
          level: currentLevel,
        );
        world.add(boss);
      }
    });
  }

  void _completeLevel() {
    // Prevent multiple completions
    if (gameState == GameState.levelComplete) return;

    gameState = GameState.levelComplete;
    AudioManager().playLevelComplete();
    currentLevel++;
    levelNotifier.value = currentLevel;

    if (currentLevel > playerData.maxUnlockedLevel) {
      playerData.maxUnlockedLevel = currentLevel;
    }

    // Auto-save progress after each level
    playerData.save();

    onLevelComplete?.call();
  }

  void _completeMission() {
    // Prevent multiple completions
    if (gameState == GameState.levelComplete) return;

    gameState = GameState.levelComplete;
    AudioManager().playLevelComplete();

    // Complete mission with final score and health
    if (missionManager != null && mission != null) {
      missionManager!.completeMission(
        scoreManager.score,
        player.health,
      );

      // Award mission rewards
      playerData.coins += mission!.rewardCoins;
      coinsNotifier.value = playerData.coins;
    }

    // Save progress
    playerData.save();
    missionManager?.save();

    onLevelComplete?.call();
  }

  void continueToNextLevel() {
    enemiesKilledThisLevel = 0;
    _levelStartDelay = 2.0; // Reset delay for new level

    // Give bonus bomb each level (max 5)
    if (bombCount < 5) {
      bombCount++;
      bombNotifier.value = bombCount;
    }

    _calculateLevelRequirements();
    gameState = GameState.playing;
    spawnManager.reset();
  }

  void onEnemyKilled(int points, int coins, {EnemyType? enemyType}) {
    scoreManager.addScore(points);
    scoreNotifier.value = scoreManager.score;

    playerData.coins += coins;
    coinsNotifier.value = playerData.coins;

    enemiesKilledThisLevel++;
    playerData.totalEnemiesKilled++;

    // Track mission progress
    if (isMissionMode && missionManager != null) {
      missionManager!.onEnemyKilled(enemyType);
      missionManager!.onCoinCollected(coins);
    }
  }

  void onBossDefeated() {
    playerData.totalBossesDefeated++;

    // Track mission progress
    if (isMissionMode && missionManager != null) {
      missionManager!.onBossDefeated();
    }

    if (!isMissionMode) {
      _completeLevel();
    }
  }

  void onPlayerHit(int damage) {
    player.takeDamage(damage);
    healthNotifier.value = player.health;

    // Track damage for mission
    if (isMissionMode && missionManager != null) {
      missionManager!.onDamageTaken(damage);
    }

    if (player.health <= 0) {
      _gameOver();
    }
  }

  void _gameOver() {
    gameState = GameState.gameOver;
    AudioManager().playGameOver();
    AudioManager().stopBackgroundMusic();

    if (scoreManager.score > playerData.highScore) {
      playerData.highScore = scoreManager.score;
    }

    playerData.save();
    onGameOver?.call();
  }

  void spawnPowerUp(Vector2 position) {
    if (Math.random() < GameConstants.powerUpDropChance) {
      final types = PowerUpType.values;
      final type = types[Math.randomInt(types.length)];
      world.add(PowerUp(position: position, type: type));
    }
  }

  void collectPowerUp(PowerUpType type) {
    switch (type) {
      case PowerUpType.health:
        player.heal(30);
        healthNotifier.value = player.health;
        break;
      case PowerUpType.shield:
        player.activateShield(5.0);
        break;
      case PowerUpType.weaponUpgrade:
        player.upgradeWeaponTemporary();
        break;
      case PowerUpType.speedBoost:
        player.activateSpeedBoost(5.0);
        break;
      case PowerUpType.scoreMultiplier:
        scoreManager.activateMultiplier(2.0, 10.0);
        break;
      case PowerUpType.bomb:
        _useBomb();
        break;
    }
  }

  void _useBomb() {
    // Called from power-up - free bomb
    _executeBomb();
  }

  /// Use bomb from button - requires bomb count
  bool useBomb() {
    if (bombCount <= 0) return false;
    if (gameState != GameState.playing) return false;

    bombCount--;
    bombNotifier.value = bombCount;
    _executeBomb();
    return true;
  }

  void _executeBomb() {
    // Screen flash effect
    world.add(BombFlashEffect());

    // Remove all enemies on screen
    world.children.whereType<AnimatedEnemy>().forEach((enemy) {
      world.add(AnimatedExplosion(position: enemy.position, isLarge: true));
      onEnemyKilled(enemy.points, enemy.coins, enemyType: enemy.type);
      enemy.removeFromParent();
    });

    // Remove all enemy bullets
    world.children.whereType<Bullet>().where((b) => b.isEnemyBullet).forEach((bullet) {
      bullet.removeFromParent();
    });

    // Damage boss if present
    world.children.whereType<Boss>().forEach((boss) {
      boss.takeDamage(50);
    });
  }

  void pauseGame() {
    gameState = GameState.paused;
    pauseEngine();
    AudioManager().pauseBackgroundMusic();

    // Auto-save on pause (in case app is killed)
    playerData.save();
    if (isMissionMode) {
      missionManager?.save();
    }

    onPause?.call();
  }

  void resumeGame() {
    gameState = GameState.playing;
    resumeEngine();
    AudioManager().resumeBackgroundMusic();
  }

  void restartGame() {
    // Reset everything
    currentLevel = 1;
    enemiesKilledThisLevel = 0;
    _levelStartDelay = 2.0; // Reset delay
    bombCount = 3; // Reset bombs
    bombNotifier.value = bombCount;
    scoreManager.reset();
    _calculateLevelRequirements();

    // Reset mission completion flag
    _missionCompleted = false;

    // Restart mission if in mission mode
    if (isMissionMode && mission != null) {
      missionManager?.startMission(mission!);

      // Re-enable space events if mission has them
      if (mission!.hasSpaceEvents) {
        spaceEventManager?.reset();
        spaceEventManager?.enableEvents(
          allowedEvents: mission!.allowedEvents,
        );
      }
    }

    // Remove all game components
    world.children.whereType<AnimatedEnemy>().forEach((e) => e.removeFromParent());
    world.children.whereType<Bullet>().forEach((b) => b.removeFromParent());
    world.children.whereType<PowerUp>().forEach((p) => p.removeFromParent());
    world.children.whereType<Boss>().forEach((b) => b.removeFromParent());

    // Remove space event components
    if (spaceEventManager != null) {
      spaceEventManager!.reset();
    }

    // Reset player
    player.reset();
    healthNotifier.value = player.health;
    livesNotifier.value = player.lives;
    scoreNotifier.value = 0;
    levelNotifier.value = 1;

    gameState = GameState.playing;
    resumeEngine();
    AudioManager().playBackgroundMusic();
  }

  // Touch controls
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _isFiring = true;
    _fireTimer = GameConstants.fireRate; // Fire immediately
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (gameState != GameState.playing) return;

    final delta = event.localDelta;
    player.move(Vector2(delta.x, delta.y));
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isFiring = false;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (gameState != GameState.playing) return;
    _shoot();
  }

  @override
  Color backgroundColor() => GameColors.background;
}

// Simple random helper
class Math {
  static final _random = math.Random();

  static double random() => _random.nextDouble();
  static int randomInt(int max) => _random.nextInt(max);
}
