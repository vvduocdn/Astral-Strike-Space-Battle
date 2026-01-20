import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/player_data.dart';
import '../game/managers/audio_manager.dart';

class ShopScreen extends StatefulWidget {
  final PlayerData playerData;

  const ShopScreen({super.key, required this.playerData});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      appBar: AppBar(
        backgroundColor: GameColors.backgroundLight,
        title: const Text('SHOP', style: TextStyle(letterSpacing: 4)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: GameColors.coin),
                const SizedBox(width: 6),
                Text(
                  '${widget.playerData.coins}',
                  style: const TextStyle(
                    color: GameColors.coin,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: GameColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.bolt), text: 'WEAPONS'),
            Tab(icon: Icon(Icons.rocket), text: 'SHIP'),
            Tab(icon: Icon(Icons.health_and_safety), text: 'UPGRADES'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWeaponsTab(),
          _buildShipsTab(),
          _buildUpgradesTab(),
        ],
      ),
    );
  }

  Widget _buildWeaponsTab() {
    final weapons = [
      _WeaponItem(
        type: WeaponType.laser,
        name: 'LASER',
        description: 'Basic weapon, fast fire rate',
        icon: Icons.electric_bolt,
        color: GameColors.primary,
      ),
      _WeaponItem(
        type: WeaponType.spread,
        name: 'SPREAD',
        description: 'Fires in 3-5 directions',
        icon: Icons.call_split,
        color: GameColors.secondary,
        unlockLevel: 3,
      ),
      _WeaponItem(
        type: WeaponType.missile,
        name: 'MISSILE',
        description: 'Homing missiles',
        icon: Icons.rocket_launch,
        color: GameColors.warning,
        unlockLevel: 6,
      ),
      _WeaponItem(
        type: WeaponType.plasma,
        name: 'PLASMA',
        description: 'Piercing shots',
        icon: Icons.lens_blur,
        color: GameColors.accent,
        unlockLevel: 10,
      ),
      _WeaponItem(
        type: WeaponType.thunder,
        name: 'THUNDER',
        description: 'Chain lightning',
        icon: Icons.flash_on,
        color: Colors.white,
        unlockLevel: 15,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: weapons.length,
      itemBuilder: (context, index) {
        final weapon = weapons[index];
        final level = widget.playerData.weaponLevels[weapon.type] ?? 0;
        final isUnlocked = level > 0;
        final canUnlock = widget.playerData.maxUnlockedLevel >= weapon.unlockLevel;

        return _buildWeaponCard(weapon, level, isUnlocked, canUnlock);
      },
    );
  }

  Widget _buildWeaponCard(
    _WeaponItem weapon,
    int level,
    bool isUnlocked,
    bool canUnlock,
  ) {
    final isSelected = widget.playerData.currentWeapon == weapon.type;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: GameColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? weapon.color : weapon.color.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isUnlocked ? () => _selectWeapon(weapon.type) : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: weapon.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    weapon.icon,
                    color: isUnlocked ? weapon.color : Colors.grey,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weapon.name,
                        style: TextStyle(
                          color: isUnlocked ? weapon.color : Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        weapon.description,
                        style: TextStyle(
                          color: isUnlocked
                              ? GameColors.textDark
                              : Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                      if (isUnlocked)
                        Text(
                          'Level $level/5',
                          style: TextStyle(
                            color: weapon.color,
                            fontSize: 12,
                          ),
                        ),
                      if (!isUnlocked)
                        Text(
                          canUnlock
                              ? 'Tap to unlock (100 coins)'
                              : 'Unlock at level ${weapon.unlockLevel}',
                          style: TextStyle(
                            color: canUnlock
                                ? GameColors.warning
                                : Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isUnlocked && level < 5)
                  ElevatedButton(
                    onPressed: () => _upgradeWeapon(weapon.type, level),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: weapon.color,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('${GameConstants.weaponUpgradePrice * level}'),
                  ),
                if (!isUnlocked && canUnlock)
                  ElevatedButton(
                    onPressed: () => _unlockWeapon(weapon.type),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GameColors.coin,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('100'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShipsTab() {
    final ships = [
      {'name': 'FIGHTER', 'color': GameColors.primary, 'speed': 1.0, 'health': 1.0},
      {'name': 'SPEEDER', 'color': GameColors.warning, 'speed': 1.3, 'health': 0.8},
      {'name': 'TANK', 'color': Colors.grey, 'speed': 0.8, 'health': 1.5},
      {'name': 'STEALTH', 'color': GameColors.accent, 'speed': 1.1, 'health': 0.9},
      {'name': 'DESTROYER', 'color': GameColors.danger, 'speed': 0.9, 'health': 1.3},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ships.length,
      itemBuilder: (context, index) {
        final ship = ships[index];
        final isUnlocked = index <= widget.playerData.maxUnlockedLevel ~/ 5;
        final isSelected = widget.playerData.currentShipIndex == index;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: GameColors.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? (ship['color'] as Color)
                  : (ship['color'] as Color).withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isUnlocked ? () => _selectShip(index) : null,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: (ship['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.rocket,
                        color: isUnlocked ? ship['color'] as Color : Colors.grey,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ship['name'] as String,
                            style: TextStyle(
                              color: isUnlocked
                                  ? ship['color'] as Color
                                  : Colors.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildStatBar(
                                'SPD',
                                ship['speed'] as double,
                                GameColors.warning,
                              ),
                              const SizedBox(width: 12),
                              _buildStatBar(
                                'HP',
                                ship['health'] as double,
                                GameColors.success,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!isUnlocked)
                      Text(
                        'Lv ${index * 5}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: GameColors.success),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatBar(String label, double value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: GameColors.textDark, fontSize: 10),
          ),
          const SizedBox(height: 2),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0, 1.5) / 1.5,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildUpgradeCard(
          'HEALTH',
          'Increase max health',
          Icons.favorite,
          GameColors.health,
          widget.playerData.healthLevel,
          () => _upgradeHealth(),
        ),
        _buildUpgradeCard(
          'SPEED',
          'Increase movement speed',
          Icons.speed,
          GameColors.warning,
          widget.playerData.speedLevel,
          () => _upgradeSpeed(),
        ),
        _buildUpgradeCard(
          'SHIELD',
          'Increase shield duration',
          Icons.shield,
          GameColors.shield,
          widget.playerData.shieldLevel,
          () => _upgradeShield(),
        ),
      ],
    );
  }

  Widget _buildUpgradeCard(
    String name,
    String description,
    IconData icon,
    Color color,
    int level,
    VoidCallback onUpgrade,
  ) {
    final price = 150 * level;
    final maxLevel = 10;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: GameColors.textDark,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Level $level/$maxLevel',
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ],
            ),
          ),
          if (level < maxLevel)
            ElevatedButton(
              onPressed: widget.playerData.coins >= price ? onUpgrade : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
              child: Text('$price'),
            ),
          if (level >= maxLevel)
            const Text('MAX', style: TextStyle(color: GameColors.success)),
        ],
      ),
    );
  }

  void _selectWeapon(WeaponType type) {
    AudioManager().playMenuSelect();
    setState(() {
      widget.playerData.currentWeapon = type;
    });
    widget.playerData.save();
  }

  void _unlockWeapon(WeaponType type) {
    if (widget.playerData.coins >= 100) {
      AudioManager().playPowerUp();
      setState(() {
        widget.playerData.coins -= 100;
        widget.playerData.weaponLevels[type] = 1;
        widget.playerData.currentWeapon = type;
      });
      widget.playerData.save();
    }
  }

  void _upgradeWeapon(WeaponType type, int currentLevel) {
    final price = GameConstants.weaponUpgradePrice * currentLevel;
    if (widget.playerData.coins >= price && currentLevel < 5) {
      AudioManager().playWeaponUpgrade();
      setState(() {
        widget.playerData.coins -= price;
        widget.playerData.weaponLevels[type] = currentLevel + 1;
      });
      widget.playerData.save();
    }
  }

  void _selectShip(int index) {
    AudioManager().playMenuSelect();
    setState(() {
      widget.playerData.currentShipIndex = index;
    });
    widget.playerData.save();
  }

  void _upgradeHealth() {
    final price = 150 * widget.playerData.healthLevel;
    if (widget.playerData.coins >= price && widget.playerData.healthLevel < 10) {
      AudioManager().playPowerUp();
      setState(() {
        widget.playerData.coins -= price;
        widget.playerData.healthLevel++;
      });
      widget.playerData.save();
    }
  }

  void _upgradeSpeed() {
    final price = 150 * widget.playerData.speedLevel;
    if (widget.playerData.coins >= price && widget.playerData.speedLevel < 10) {
      AudioManager().playPowerUp();
      setState(() {
        widget.playerData.coins -= price;
        widget.playerData.speedLevel++;
      });
      widget.playerData.save();
    }
  }

  void _upgradeShield() {
    final price = 150 * (widget.playerData.shieldLevel + 1);
    if (widget.playerData.coins >= price && widget.playerData.shieldLevel < 10) {
      AudioManager().playPowerUp();
      setState(() {
        widget.playerData.coins -= price;
        widget.playerData.shieldLevel++;
      });
      widget.playerData.save();
    }
  }
}

class _WeaponItem {
  final WeaponType type;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int unlockLevel;

  _WeaponItem({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.unlockLevel = 1,
  });
}
