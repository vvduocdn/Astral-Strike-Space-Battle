import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class PlayerData {
  int coins;
  int highScore;
  int currentLevel;
  int maxUnlockedLevel;
  WeaponType currentWeapon;
  int currentShipIndex;
  Map<WeaponType, int> weaponLevels;
  int healthLevel;
  int speedLevel;
  int shieldLevel;
  List<String> unlockedAchievements;
  DateTime? lastDailyReward;
  int dailyRewardStreak;
  int totalEnemiesKilled;
  int totalBossesDefeated;
  int totalPlayTime; // in seconds

  PlayerData({
    this.coins = 0,
    this.highScore = 0,
    this.currentLevel = 1,
    this.maxUnlockedLevel = 1,
    this.currentWeapon = WeaponType.laser,
    this.currentShipIndex = 0,
    Map<WeaponType, int>? weaponLevels,
    this.healthLevel = 1,
    this.speedLevel = 1,
    this.shieldLevel = 0,
    List<String>? unlockedAchievements,
    this.lastDailyReward,
    this.dailyRewardStreak = 0,
    this.totalEnemiesKilled = 0,
    this.totalBossesDefeated = 0,
    this.totalPlayTime = 0,
  })  : weaponLevels = weaponLevels ??
            {
              WeaponType.laser: 1,
              WeaponType.spread: 0,
              WeaponType.missile: 0,
              WeaponType.plasma: 0,
              WeaponType.thunder: 0,
            },
        unlockedAchievements = unlockedAchievements ?? [];

  int get maxHealth => GameConstants.playerMaxHealth + (healthLevel - 1) * 20;
  double get speedMultiplier => 1.0 + (speedLevel - 1) * 0.1;
  double get shieldDuration => shieldLevel * 2.0;

  Map<String, dynamic> toJson() => {
        'coins': coins,
        'highScore': highScore,
        'currentLevel': currentLevel,
        'maxUnlockedLevel': maxUnlockedLevel,
        'currentWeapon': currentWeapon.index,
        'currentShipIndex': currentShipIndex,
        'weaponLevels':
            weaponLevels.map((k, v) => MapEntry(k.index.toString(), v)),
        'healthLevel': healthLevel,
        'speedLevel': speedLevel,
        'shieldLevel': shieldLevel,
        'unlockedAchievements': unlockedAchievements,
        'lastDailyReward': lastDailyReward?.toIso8601String(),
        'dailyRewardStreak': dailyRewardStreak,
        'totalEnemiesKilled': totalEnemiesKilled,
        'totalBossesDefeated': totalBossesDefeated,
        'totalPlayTime': totalPlayTime,
      };

  factory PlayerData.fromJson(Map<String, dynamic> json) {
    final weaponLevelsMap = <WeaponType, int>{};
    if (json['weaponLevels'] != null) {
      (json['weaponLevels'] as Map<String, dynamic>).forEach((k, v) {
        weaponLevelsMap[WeaponType.values[int.parse(k)]] = v as int;
      });
    }

    return PlayerData(
      coins: json['coins'] ?? 0,
      highScore: json['highScore'] ?? 0,
      currentLevel: json['currentLevel'] ?? 1,
      maxUnlockedLevel: json['maxUnlockedLevel'] ?? 1,
      currentWeapon: WeaponType.values[json['currentWeapon'] ?? 0],
      currentShipIndex: json['currentShipIndex'] ?? 0,
      weaponLevels: weaponLevelsMap.isEmpty ? null : weaponLevelsMap,
      healthLevel: json['healthLevel'] ?? 1,
      speedLevel: json['speedLevel'] ?? 1,
      shieldLevel: json['shieldLevel'] ?? 0,
      unlockedAchievements:
          List<String>.from(json['unlockedAchievements'] ?? []),
      lastDailyReward: json['lastDailyReward'] != null
          ? DateTime.parse(json['lastDailyReward'])
          : null,
      dailyRewardStreak: json['dailyRewardStreak'] ?? 0,
      totalEnemiesKilled: json['totalEnemiesKilled'] ?? 0,
      totalBossesDefeated: json['totalBossesDefeated'] ?? 0,
      totalPlayTime: json['totalPlayTime'] ?? 0,
    );
  }

  static Future<PlayerData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('playerData');
    if (jsonStr != null) {
      return PlayerData.fromJson(json.decode(jsonStr));
    }
    return PlayerData();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('playerData', json.encode(toJson()));
  }
}
