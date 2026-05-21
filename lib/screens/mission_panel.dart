import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/mission.dart';
import '../theme/app_theme.dart';
import '../widgets/hud_elements.dart';

class MissionListPanel extends StatelessWidget {
  final List<Mission> missions;
  final void Function(Mission) onSelect;

  const MissionListPanel({super.key, required this.missions, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return HudPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HudLabel('AVAILABLE OPERATIONS', color: ZeroPointColors.accent),
          const SizedBox(height: 16),
          ...missions.map((m) => _MissionTile(mission: m, onTap: () => onSelect(m))),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MissionTile extends StatelessWidget {
  final Mission mission;
  final VoidCallback onTap;

  const _MissionTile({required this.mission, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = mission.status == MissionStatus.completed
        ? ZeroPointColors.success
        : ZeroPointColors.accent;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 48,
              color: statusColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  MissionProgressBar(progress: mission.progress, color: statusColor),
                  const SizedBox(height: 4),
                  HudLabel('${mission.completedCount}/${mission.waypoints.length} NODES  ·  ${mission.type.name.toUpperCase()}'),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: ZeroPointColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class CreateMissionSheet extends StatefulWidget {
  final void Function(Mission) onCreated;

  const CreateMissionSheet({super.key, required this.onCreated});

  @override
  State<CreateMissionSheet> createState() => _CreateMissionSheetState();
}

class _CreateMissionSheetState extends State<CreateMissionSheet> {
  final _titleCtrl = TextEditingController();
  final _briefCtrl = TextEditingController();
  MissionType _type = MissionType.explore;
  final List<_WaypointInput> _waypointInputs = [_WaypointInput()];

  @override
  Widget build(BuildContext context) {
    return HudPanel(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HudLabel('CREATE OPERATION', color: ZeroPointColors.accent),
          const SizedBox(height: 20),
          _HudTextField(controller: _titleCtrl, label: 'OPERATION NAME'),
          const SizedBox(height: 12),
          _HudTextField(controller: _briefCtrl, label: 'BRIEFING', maxLines: 2),
          const SizedBox(height: 12),
          const HudLabel('MISSION TYPE'),
          const SizedBox(height: 8),
          Row(
            children: MissionType.values
                .map((t) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _type = t),
                        child: HudPanel(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          borderColor: _type == t ? ZeroPointColors.accent : ZeroPointColors.border,
                          child: HudLabel(
                            t.name.toUpperCase(),
                            color: _type == t ? ZeroPointColors.accent : ZeroPointColors.textSecondary,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          const HudLabel('WAYPOINTS (USE DEFAULT TAIPEI LOCATIONS)'),
          const SizedBox(height: 8),
          Text(
            'Default sample waypoints will be added. Tap waypoints on map to customize in a future update.',
            style: const TextStyle(fontSize: 11, color: ZeroPointColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _submit,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: ZeroPointColors.accentDim,
                border: Border.all(color: ZeroPointColors.accent),
              ),
              alignment: Alignment.center,
              child: const HudLabel('DEPLOY MISSION', color: ZeroPointColors.accent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty) return;
    final mission = Mission(
      title: _titleCtrl.text.trim().toUpperCase(),
      briefing: _briefCtrl.text.trim().isEmpty ? 'No briefing provided.' : _briefCtrl.text.trim(),
      type: _type,
      createdBy: 'GHOST-01',
      waypoints: [
        Waypoint(
          name: 'Alpha Point',
          description: 'First node',
          position: const LatLng(25.0480, 121.5170),
        ),
        Waypoint(
          name: 'Bravo Point',
          description: 'Second node',
          position: const LatLng(25.0330, 121.5654),
        ),
      ],
    );
    widget.onCreated(mission);
    Navigator.pop(context);
  }
}

class _WaypointInput {
  final nameCtrl = TextEditingController();
  final latCtrl = TextEditingController();
  final lngCtrl = TextEditingController();
}

class _HudTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const _HudTextField({required this.controller, required this.label, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HudLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: ZeroPointColors.textPrimary, letterSpacing: 0.5),
          decoration: InputDecoration(
            filled: true,
            fillColor: ZeroPointColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: const BorderSide(color: ZeroPointColors.border),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: ZeroPointColors.border),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: ZeroPointColors.accent),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}
