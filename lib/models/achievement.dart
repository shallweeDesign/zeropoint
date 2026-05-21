enum AchievementRarity { common, rare, epic, legendary }

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementRarity rarity;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.rarity,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement unlock() => Achievement(
        id: id,
        title: title,
        description: description,
        icon: icon,
        rarity: rarity,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );

  static final List<Achievement> defaults = [
    const Achievement(
      id: 'first_mission',
      title: 'FIRST CONTACT',
      description: 'Complete your first mission',
      icon: '🎯',
      rarity: AchievementRarity.common,
    ),
    const Achievement(
      id: 'five_waypoints',
      title: 'PATHFINDER',
      description: 'Complete 5 waypoints',
      icon: '📍',
      rarity: AchievementRarity.common,
    ),
    const Achievement(
      id: 'squad_up',
      title: 'STRAND CONNECTED',
      description: 'Join a mission with a squad',
      icon: '🔗',
      rarity: AchievementRarity.rare,
    ),
    const Achievement(
      id: 'three_missions',
      title: 'OPERATIVE',
      description: 'Complete 3 missions',
      icon: '⚡',
      rarity: AchievementRarity.rare,
    ),
    const Achievement(
      id: 'explorer',
      title: 'ZERO POINT REACHED',
      description: 'Complete a mission across 3+ countries',
      icon: '🌍',
      rarity: AchievementRarity.epic,
    ),
    const Achievement(
      id: 'ghost',
      title: 'GHOST PROTOCOL',
      description: 'Complete 10 missions solo',
      icon: '👻',
      rarity: AchievementRarity.legendary,
    ),
  ];
}
