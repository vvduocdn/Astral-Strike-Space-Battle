import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../game/managers/audio_manager.dart';
import '../utils/app_icon_generator.dart';
import 'policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;
  double _soundVolume = 0.8;
  double _musicVolume = 0.5;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _musicEnabled = prefs.getBool('musicEnabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
      _soundVolume = prefs.getDouble('soundVolume') ?? 0.8;
      _musicVolume = prefs.getDouble('musicVolume') ?? 0.5;
    });
  }

  Future<void> _saveSettings() async {
    AudioManager().playButtonClick();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('musicEnabled', _musicEnabled);
    await prefs.setBool('vibrationEnabled', _vibrationEnabled);
    await prefs.setDouble('soundVolume', _soundVolume);
    await prefs.setDouble('musicVolume', _musicVolume);

    // Sync with AudioManager
    AudioManager().setSoundEnabled(_soundEnabled);
    AudioManager().setMusicEnabled(_musicEnabled);
    AudioManager().setSoundVolume(_soundVolume);
    AudioManager().setMusicVolume(_musicVolume);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      appBar: AppBar(
        backgroundColor: GameColors.backgroundLight,
        title: const Text('SETTINGS', style: TextStyle(letterSpacing: 4)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle('AUDIO'),
          _buildSwitchTile('Sound Effects', Icons.volume_up, _soundEnabled, (
            value,
          ) {
            setState(() => _soundEnabled = value);
            _saveSettings();
          }),
          if (_soundEnabled)
            _buildSliderTile('Sound Volume', _soundVolume, (value) {
              setState(() => _soundVolume = value);
              _saveSettings();
            }),
          const SizedBox(height: 8),
          _buildSwitchTile('Music', Icons.music_note, _musicEnabled, (value) {
            setState(() => _musicEnabled = value);
            _saveSettings();
          }),
          if (_musicEnabled)
            _buildSliderTile('Music Volume', _musicVolume, (value) {
              setState(() => _musicVolume = value);
              _saveSettings();
            }),
          const SizedBox(height: 24),
          _buildSectionTitle('CONTROLS'),
          _buildSwitchTile('Vibration', Icons.vibration, _vibrationEnabled, (
            value,
          ) {
            setState(() => _vibrationEnabled = value);
            _saveSettings();
          }),
          const SizedBox(height: 24),
          _buildSectionTitle('DATA'),
          _buildActionTile(
            'Reset Progress',
            Icons.restore,
            GameColors.warning,
            () => _showResetDialog(),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('LEGAL'),
          _buildActionTile(
            'Privacy Policy & Terms',
            Icons.policy,
            GameColors.primary,
            () => _openPolicy(),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('DEVELOPER'),
          _buildActionTile(
            'App Icon Preview',
            Icons.image,
            GameColors.accent,
            () => _openIconGenerator(),
          ),
          const SizedBox(height: 40),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: GameColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: GameColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: GameColors.text),
        title: Text(title, style: const TextStyle(color: GameColors.text)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: GameColors.primary,
        ),
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.backgroundLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: GameColors.textDark, fontSize: 12),
          ),
          Slider(
            value: value,
            onChanged: onChanged,
            activeColor: GameColors.primary,
            inactiveColor: GameColors.backgroundLight,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: GameColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color)),
        trailing: Icon(Icons.chevron_right, color: color),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GameColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.rocket_launch, color: GameColors.primary, size: 48),
          const SizedBox(height: 12),
          const Text(
            'ASTRAL STRIKE',
            style: TextStyle(
              color: GameColors.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const Text(
            'Space Battle',
            style: TextStyle(color: GameColors.textDark, fontSize: 12),
          ),
          const SizedBox(height: 4),
          const Text(
            'Version 1.0.1',
            style: TextStyle(color: GameColors.textDark, fontSize: 14),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _openPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PolicyScreen()),
    );
  }

  void _openIconGenerator() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AppIconGenerator()),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameColors.backgroundLight,
        title: const Text(
          'Reset Progress?',
          style: TextStyle(color: GameColors.text),
        ),
        content: const Text(
          'This will delete all your progress, including coins, levels, and achievements. This action cannot be undone.',
          style: TextStyle(color: GameColors.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('playerData');
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text(
              'RESET',
              style: TextStyle(color: GameColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
