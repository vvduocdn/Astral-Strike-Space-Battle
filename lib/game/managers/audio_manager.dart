import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _soundVolume = 0.8;
  double _musicVolume = 0.5;
  bool _initialized = false;
  bool _isPlaying = false; // Prevent concurrent plays

  // Cooldown tracking to prevent sound spam
  final Map<String, int> _lastPlayTime = {};

  // Cooldown durations in milliseconds
  static const int _shootCooldown = 100; // Increased cooldown

  // Chỉ giữ 1 âm thanh bắn để tránh lỗi
  final String _laserSound = 'laser1.ogg';

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  Future<void> init() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _musicEnabled = prefs.getBool('musicEnabled') ?? true;
    _soundVolume = prefs.getDouble('soundVolume') ?? 0.8;
    _musicVolume = prefs.getDouble('musicVolume') ?? 0.5;

    _initialized = true;

    // Preload sound
    await _preloadAudio();
  }

  Future<void> _preloadAudio() async {
    try {
      await FlameAudio.audioCache.load(_laserSound);
    } catch (e) {
      // Silent fail
    }
  }

  // Check if sound can play (cooldown check)
  bool _canPlay(String soundType, int cooldownMs) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastTime = _lastPlayTime[soundType] ?? 0;

    if (now - lastTime < cooldownMs) {
      return false;
    }

    _lastPlayTime[soundType] = now;
    return true;
  }

  // Play shoot sound - CHỈ GIỮ ÂM THANH NÀY
  void playShoot() {
    if (!_soundEnabled || _isPlaying) return;
    if (!_canPlay('shoot', _shootCooldown)) return;

    _isPlaying = true;

    // Use microtask to avoid blocking
    Future.microtask(() async {
      try {
        await FlameAudio.play(_laserSound, volume: _soundVolume * 0.4);
      } catch (e) {
        // Silent fail - audio errors should not crash the game
      } finally {
        _isPlaying = false;
      }
    });
  }

  // Các âm thanh khác - TẮT HẾT
  void playExplosion({bool isLarge = false}) {}
  void playBossExplosion() {}
  void playPowerUp() {}
  void playHit() {}
  void playPlayerDeath() {}
  void playBossWarning() {}
  void playLevelComplete() {}
  void playGameOver() {}
  void playButtonClick() {}
  void playMenuSelect() {}
  void playCoinCollect() {}
  void playShieldActivate() {}
  void playShieldBreak() {}
  void playWeaponUpgrade() {}
  void playEnemyShoot() {}
  void playWarp() {}

  // Background music
  Future<void> playBackgroundMusic() async {
    if (_musicEnabled) {
      try {
        await FlameAudio.bgm.play('background_music.mp3', volume: _musicVolume);
      } catch (e) {
        // Silent fail
      }
    }
  }

  void stopBackgroundMusic() {
    try {
      FlameAudio.bgm.stop();
    } catch (e) {
      // Ignore
    }
  }

  void pauseBackgroundMusic() {
    try {
      FlameAudio.bgm.pause();
    } catch (e) {
      // Ignore
    }
  }

  void resumeBackgroundMusic() {
    if (_musicEnabled) {
      try {
        FlameAudio.bgm.resume();
      } catch (e) {
        // Ignore
      }
    }
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    _saveSettings();
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      stopBackgroundMusic();
    } else {
      playBackgroundMusic();
    }
    _saveSettings();
  }

  void setSoundVolume(double volume) {
    _soundVolume = volume;
    _saveSettings();
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume;
    try {
      FlameAudio.bgm.audioPlayer.setVolume(volume);
    } catch (e) {
      // Ignore
    }
    _saveSettings();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('musicEnabled', _musicEnabled);
    await prefs.setDouble('soundVolume', _soundVolume);
    await prefs.setDouble('musicVolume', _musicVolume);
  }

  /// Stop all sound effects (keep background music)
  void stopAllSfx() {
    _lastPlayTime.clear();
    _isPlaying = false;
  }

  /// Called when exiting game screen
  void onExitGame() {
    _lastPlayTime.clear();
    _isPlaying = false;
    try {
      FlameAudio.audioCache.clearAll();
    } catch (e) {
      // Ignore
    }
  }

  void dispose() {
    _lastPlayTime.clear();
    _isPlaying = false;
    try {
      FlameAudio.audioCache.clearAll();
      FlameAudio.bgm.dispose();
    } catch (e) {
      // Ignore
    }
  }
}
