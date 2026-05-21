import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../providers/mission_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/hud_elements.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MissionProvider>();
    final unlocked = provider.achievements.where((a) => a.isUnlocked).length;

    return Scaffold(
      backgroundColor: ZeroPointColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: ZeroPointColors.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  const HudLabel('MEDALS & ACHIEVEMENTS', color: ZeroPointColors.accent, fontSize: 14),
                  const Spacer(),
                  HudLabel('$unlocked/${provider.achievements.length} UNLOCKED'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MissionProgressBar(progress: unlocked / provider.achievements.length),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: provider.achievements
                    .map((a) => _AchievementCard(achievement: a))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  Color get _rarityColor => switch (achievement.rarity) {
        AchievementRarity.common => ZeroPointColors.textSecondary,
        AchievementRarity.rare => const Color(0xFF4DA6FF),
        AchievementRarity.epic => const Color(0xFFAA44FF),
        AchievementRarity.legendary => ZeroPointColors.accent,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HudPanel(
        borderColor: achievement.isUnlocked ? _rarityColor : ZeroPointColors.border,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: achievement.isUnlocked ? _rarityColor.withOpacity(0.15) : ZeroPointColors.surface,
                border: Border.all(color: achievement.isUnlocked ? _rarityColor : ZeroPointColors.border),
              ),
              alignment: Alignment.center,
              child: Text(
                achievement.isUnlocked ? achievement.icon : '?',
                style: TextStyle(fontSize: achievement.isUnlocked ? 24 : 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        achievement.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: achievement.isUnlocked ? ZeroPointColors.textPrimary : ZeroPointColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      HudPanel(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        borderColor: _rarityColor.withOpacity(0.5),
                        child: HudLabel(
                          achievement.rarity.name.toUpperCase(),
                          color: _rarityColor,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.isUnlocked ? achievement.description : '???',
                    style: TextStyle(
                      fontSize: 12,
                      color: achievement.isUnlocked ? ZeroPointColors.textSecondary : ZeroPointColors.textMuted,
                    ),
                  ),
                  if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
                    const SizedBox(height: 4),
                    HudLabel(
                      'UNLOCKED ${_formatDate(achievement.unlockedAt!)}',
                      color: _rarityColor,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
}
