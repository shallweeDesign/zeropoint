import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/mission.dart';
import '../providers/mission_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/hud_elements.dart';
import 'mission_panel.dart';

const _mapboxToken = String.fromEnvironment('MAPBOX_TOKEN', defaultValue: '');

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  bool _showMissionList = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MissionProvider>();
    final active = provider.activeMission;

    return Scaffold(
      backgroundColor: ZeroPointColors.bg,
      body: Stack(
        children: [
          _buildMap(provider),
          _buildTopBar(provider),
          if (active != null) _buildMissionHud(active, provider),
          if (_showMissionList) _buildMissionList(provider),
          _buildBottomBar(provider),
        ],
      ),
    );
  }

  Widget _buildMap(MissionProvider provider) {
    final tileUrl = _mapboxToken.isNotEmpty
        ? 'https://api.mapbox.com/styles/v1/mapbox/dark-v11/tiles/{z}/{x}/{y}?access_token=$_mapboxToken'
        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(25.0330, 121.5654),
        initialZoom: 12,
        backgroundColor: ZeroPointColors.bg,
        onTap: (_, __) {
          if (provider.activeMissionId != null) {
            provider.clearSelection();
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: tileUrl,
          userAgentPackageName: 'com.zeropoint.zeropoint',
          tileBuilder: _mapboxToken.isEmpty ? _darkTileBuilder : null,
        ),
        // strand lines between waypoints
        PolylineLayer(
          polylines: provider.missions
              .where((m) => m.status == MissionStatus.active)
              .map((m) => Polyline(
                    points: m.waypoints.map((w) => w.position).toList(),
                    color: ZeroPointColors.accent.withOpacity(0.25),
                    strokeWidth: 1.5,
                    pattern: StrokePattern.dashed(segments: const [8, 6]),
                  ))
              .toList(),
        ),
        // waypoint markers
        MarkerLayer(
          markers: [
            for (final mission in provider.missions)
              for (final wp in mission.waypoints)
                Marker(
                  point: wp.position,
                  width: 36,
                  height: 36,
                  child: GestureDetector(
                    onTap: () => provider.selectMission(mission.id),
                    child: _WaypointMarker(
                      isCompleted: wp.isCompleted,
                      isActive: provider.activeMissionId == mission.id,
                    ),
                  ),
                ),
          ],
        ),
      ],
    );
  }

  Widget _darkTileBuilder(BuildContext ctx, Widget tile, TileImage ti) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        -0.8, 0, 0, 0, 50,
        0, -0.8, 0, 0, 50,
        0, 0, -0.8, 0, 50,
        0, 0, 0, 1, 0,
      ]),
      child: tile,
    );
  }

  Widget _buildTopBar(MissionProvider provider) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            HudPanel(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              borderColor: ZeroPointColors.accent,
              child: Row(
                children: [
                  Text(
                    '0POINT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: ZeroPointColors.accent,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            HudPanel(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: ZeroPointColors.accent, size: 14),
                  const SizedBox(width: 6),
                  HudLabel('${provider.totalCompleted} OPS COMPLETE'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionHud(Mission mission, MissionProvider provider) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 80,
      child: AccentCornerBox(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HudLabel('ACTIVE MISSION', color: ZeroPointColors.accent),
                const Spacer(),
                HudLabel('${mission.completedCount}/${mission.waypoints.length} NODES'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              mission.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: ZeroPointColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mission.briefing,
              style: const TextStyle(
                fontSize: 12,
                color: ZeroPointColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            MissionProgressBar(progress: mission.progress),
            const SizedBox(height: 12),
            ...mission.waypoints.map((wp) => _WaypointRow(
                  waypoint: wp,
                  onComplete: () => provider.completeWaypoint(mission.id, wp.id),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionList(MissionProvider provider) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showMissionList = false),
        child: Container(
          color: Colors.black54,
          alignment: Alignment.bottomCenter,
          child: MissionListPanel(
            missions: provider.missions,
            onSelect: (m) {
              provider.selectMission(m.id);
              _mapController.move(m.center, 13);
              setState(() => _showMissionList = false);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(MissionProvider provider) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: HudPanel(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        borderColor: ZeroPointColors.border,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomAction(
              icon: Icons.map_outlined,
              label: 'MISSIONS',
              onTap: () => setState(() => _showMissionList = !_showMissionList),
            ),
            _BottomAction(
              icon: Icons.add_circle_outline,
              label: 'NEW OP',
              accent: true,
              onTap: () => _showCreateDialog(context, provider),
            ),
            _BottomAction(
              icon: Icons.military_tech_outlined,
              label: 'MEDALS',
              onTap: () => Navigator.pushNamed(context, '/achievements'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, MissionProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CreateMissionSheet(
        onCreated: (mission) {
          provider.addMission(mission);
          provider.selectMission(mission.id);
          _mapController.move(mission.center, 12);
        },
      ),
    );
  }
}

class _WaypointMarker extends StatelessWidget {
  final bool isCompleted;
  final bool isActive;

  const _WaypointMarker({required this.isCompleted, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isCompleted
        ? ZeroPointColors.success
        : isActive
            ? ZeroPointColors.accent
            : ZeroPointColors.textSecondary;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
        border: Border.all(color: color, width: isActive ? 2 : 1),
        boxShadow: isActive
            ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, spreadRadius: 2)]
            : null,
      ),
      child: Icon(
        isCompleted ? Icons.check : Icons.radio_button_unchecked,
        color: color,
        size: 16,
      ),
    );
  }
}

class _WaypointRow extends StatelessWidget {
  final Waypoint waypoint;
  final VoidCallback onComplete;

  const _WaypointRow({required this.waypoint, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            waypoint.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
            color: waypoint.isCompleted ? ZeroPointColors.success : ZeroPointColors.textSecondary,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              waypoint.name,
              style: TextStyle(
                fontSize: 13,
                color: waypoint.isCompleted ? ZeroPointColors.textSecondary : ZeroPointColors.textPrimary,
                decoration: waypoint.isCompleted ? TextDecoration.lineThrough : null,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (!waypoint.isCompleted)
            GestureDetector(
              onTap: onComplete,
              child: HudPanel(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                borderColor: ZeroPointColors.accent,
                child: const HudLabel('MARK', color: ZeroPointColors.accent),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;

  const _BottomAction({required this.icon, required this.label, required this.onTap, this.accent = false});

  @override
  Widget build(BuildContext context) {
    final color = accent ? ZeroPointColors.accent : ZeroPointColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          HudLabel(label, color: color),
        ],
      ),
    );
  }
}
