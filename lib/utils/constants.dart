import 'package:flutter/material.dart';

class GameConstants {
  // Screen
  static const double gameWidth = 400;
  static const double gameHeight = 800;

  // Player
  static const double playerSpeed = 300;
  static const double playerWidth = 60;
  static const double playerHeight = 70;
  static const int playerMaxHealth = 100;
  static const int playerStartLives = 3;

  // Bullets
  static const double bulletSpeed = 500;
  static const double bulletWidth = 8;
  static const double bulletHeight = 20;
  static const double fireRate = 0.15; // seconds between shots

  // Enemies
  static const double enemySpeed = 150;
  static const double enemyWidth = 50;
  static const double enemyHeight = 50;

  // Boss
  static const double bossWidth = 120;
  static const double bossHeight = 100;
  static const int bossHealthMultiplier = 10;

  // Power-ups
  static const double powerUpSpeed = 100;
  static const double powerUpSize = 40;
  static const double powerUpDropChance = 0.15;

  // Levels
  static const int totalLevels = 50;
  static const int bossEveryLevel = 5;

  // Shop prices
  static const int weaponUpgradePrice = 100;
  static const int healthUpgradePrice = 150;
  static const int speedUpgradePrice = 120;
}

class GameColors {
  static const Color primary = Color(0xFF00D4FF);
  static const Color secondary = Color(0xFFFF6B35);
  static const Color accent = Color(0xFF7B2CBF);
  static const Color background = Color(0xFF0D1B2A);
  static const Color backgroundLight = Color(0xFF1B263B);
  static const Color text = Color(0xFFE0E1DD);
  static const Color textDark = Color(0xFF778DA9);
  static const Color success = Color(0xFF00FF88);
  static const Color danger = Color(0xFFFF3366);
  static const Color warning = Color(0xFFFFD60A);
  static const Color shield = Color(0xFF00BFFF);
  static const Color health = Color(0xFFFF4444);
  static const Color coin = Color(0xFFFFD700);
}

enum WeaponType {
  laser,
  spread,
  missile,
  plasma,
  thunder,
}

enum PowerUpType {
  health,
  shield,
  weaponUpgrade,
  speedBoost,
  scoreMultiplier,
  bomb,
}

enum EnemyType {
  basic,
  fast,
  tank,
  shooter,
  zigzag,
}

enum GameState {
  playing,
  paused,
  gameOver,
  levelComplete,
  bossWarning,
}
