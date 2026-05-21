import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/mission.dart';
import '../providers/mission_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/hud_elements.dart';
import 'mission_panel.dart';

const _mapStyle = '[{"elementType":"geometry","stylers":[{"color":"#0a0c0f"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#4a5568"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#0a0c0f"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#1a2030"}]},{"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#6b7a8d"}]},{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#556070"}]},{"featureType":"poi","stylers":[{"visibility":"off"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#1a2030"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#0f1520"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#3d4a5c"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#1e2d42"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#445566"}]},{"featureType":"transit","stylers":[{"visibility":"off"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#060810"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#1a2535"}]}]';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  bool _showMissionList = false;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

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
    return GoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(25.0330, 121.5654), zoom: 12),
      onMapCreated: (c) { _mapController = c; c.setMapStyle(_mapStyle); },
      markers: _buildMarkers(provider),
      polylines: _buildPolylines(provider),
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      onTap: (_) { if (provider.activeMissionId != null) provider.clearSelection(); },
    );
  }

  Set<Marker> _buildMarkers(MissionProvider provider) {
    final markers = <Marker>{};
    for (final mission in provider.missions) {
      for (final wp in mission.waypoints) {
        final isActive = provider.activeMissionId == mission.id;
        final hue = wp.isCompleted ? BitmapDescriptor.hueGreen : isActive ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueAzure;
        markers.add(Marker(
          markerId: MarkerId(wp.id),
          position: wp.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          infoWindow: InfoWindow(title: wp.name, snippet: wp.description),
          onTap: () => provider.selectMission(mission.id),
        ));
      }
    }
    return markers;
  }

  Set<Polyline> _buildPolylines(MissionProvider provider) {
    return provider.missions
        .where((m) => m.status == MissionStatus.active && m.waypoints.length > 1)
        .map((m) => Polyline(
              polylineId: PolylineId(m.id),
              points: m.waypoints.map((w) => w.position).toList(),
              color: const Color(0x55FF6000),
              width: 2,
              patterns: [PatternItem.dash(12), PatternItem.gap(8)],
            ))
        .toSet();
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
              child: Text('0POINT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: ZeroPointColors.accent, letterSpacing: 4)),
            ),
            const Spacer(),
            HudPanel(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(children: [
                const Icon(Icons.bolt, color: ZeroPointColors.accent, size: 14),
                const SizedBox(width: 6),
                HudLabel('${provider.totalCompleted} OPS COMPLETE'),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionHud(Mission mission, MissionProvider provider) {
    return Positioned(
      left: 12, right: 12, bottom: 80,
      child: AccentCornerBox(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              HudLabel('ACTIVE MISSION', color: ZeroPointColors.accent),
              const Spacer(),
              HudLabel('${mission.completedCount}/${mission.waypoints.length} NODES'),
            ]),
            const SizedBox(height: 8),
            Text(mission.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 2, color: ZeroPointColors.textPrimary)),
            const SizedBox(height: 4),
            Text(mission.briefing, style: const TextStyle(fontSize: 12, color: ZeroPointColors.textSecondary, height: 1.4)),
            const SizedBox(height: 12),
            MissionProgressBar(progress: mission.progress),
            const SizedBox(height: 12),
            ...mission.waypoints.map((wp) => _WaypointRow(waypoint: wp, onComplete: () => provider.completeWaypoint(mission.id, wp.id))),
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
              _mapController?.animateCamera(CameraUpdate.newLatLngZoom(m.center, 13));
              setState(() => _showMissionList = false);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(MissionProvider provider) {
    return Positioned(
      left: 0, right: 0, bottom: 0,
      child: HudPanel(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        borderColor: ZeroPointColors.border,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomAction(icon: Icons.map_outlined, label: 'MISSIONS', onTap: () => setState(() => _showMissionList = !_showMissionList)),
            _BottomAction(
              icon: Icons.add_circle_outline, label: 'NEW OP', accent: true,
              onTap: () => showModalBottomSheet(
                context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
                builder: (_) => CreateMissionSheet(onCreated: (mission) {
                  provider.addMission(mission);
                  provider.selectMission(mission.id);
                  _mapController?.animateCamera(CameraUpdate.newLatLngZoom(mission.center, 12));
                }),
              ),
            ),
            _BottomAction(icon: Icons.military_tech_outlined, label: 'MEDALS', onTap: () => Navigator.pushNamed(context, '/achievements')),
          ],
        ),
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
          Icon(waypoint.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
              color: waypoint.isCompleted ? ZeroPointColors.success : ZeroPointColors.textSecondary, size: 16),
          const SizedBox(width: 10),
          Expanded(child: Text(waypoint.name, style: TextStyle(
            fontSize: 13,
            color: waypoint.isCompleted ? ZeroPointColors.textSecondary : ZeroPointColors.textPrimary,
            decoration: waypoint.isCompleted ? TextDecoration.lineThrough : null,
            letterSpacing: 0.5,
          ))),
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
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        HudLabel(label, color: color),
      ]),
    );
  }
}
