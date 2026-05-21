import 'package:flutter/foundation.dart';
import "package:google_maps_flutter/google_maps_flutter.dart";
import '../models/mission.dart';
import '../models/achievement.dart';

class MissionProvider extends ChangeNotifier {
  final List<Mission> _missions = _sampleMissions();
  List<Achievement> _achievements = Achievement.defaults;
  String? _activeMissionId;

  List<Mission> get missions => List.unmodifiable(_missions);
  List<Achievement> get achievements => List.unmodifiable(_achievements);
  String? get activeMissionId => _activeMissionId;

  Mission? get activeMission =>
      _activeMissionId == null ? null : _missions.firstWhere((m) => m.id == _activeMissionId);

  void selectMission(String id) {
    _activeMissionId = id;
    notifyListeners();
  }

  void clearSelection() {
    _activeMissionId = null;
    notifyListeners();
  }

  void completeWaypoint(String missionId, String waypointId) {
    final mission = _missions.firstWhere((m) => m.id == missionId);
    final idx = mission.waypoints.indexWhere((w) => w.id == waypointId);
    if (idx == -1) return;
    mission.waypoints[idx] = mission.waypoints[idx].copyWith(isCompleted: true);
    if (mission.isFullyComplete) {
      mission.status = MissionStatus.completed;
      _checkAchievements();
    }
    notifyListeners();
  }

  void addMission(Mission mission) {
    _missions.add(mission);
    notifyListeners();
  }

  int get totalCompleted => _missions.where((m) => m.status == MissionStatus.completed).length;
  int get totalWaypointsCompleted =>
      _missions.fold(0, (sum, m) => sum + m.completedCount);

  void _checkAchievements() {
    _achievements = _achievements.map((a) {
      if (a.isUnlocked) return a;
      if (a.id == 'first_mission' && totalCompleted >= 1) return a.unlock();
      if (a.id == 'five_waypoints' && totalWaypointsCompleted >= 5) return a.unlock();
      if (a.id == 'three_missions' && totalCompleted >= 3) return a.unlock();
      return a;
    }).toList();
  }

  static List<Mission> _sampleMissions() => [
        Mission(
          title: 'OPERATION TAIPEI',
          briefing: 'Infiltrate the cultural district. Locate all signal points.',
          type: MissionType.explore,
          createdBy: 'GHOST-01',
          waypoints: [
            Waypoint(
              name: 'Chiang Kai-shek Memorial',
              description: 'Primary signal node. Establish uplink.',
              position: const LatLng(25.0340, 121.5215),
            ),
            Waypoint(
              name: 'Taipei 101',
              description: 'Secondary node. Confirm visual contact.',
              position: const LatLng(25.0330, 121.5654),
            ),
            Waypoint(
              name: 'Shilin Night Market',
              description: 'Extract intel from local operatives.',
              position: const LatLng(25.0880, 121.5240),
            ),
          ],
        ),
        Mission(
          title: 'GHOST COAST',
          briefing: 'Coastal recon. Document all points of interest along the strand.',
          type: MissionType.reach,
          createdBy: 'GHOST-01',
          waypoints: [
            Waypoint(
              name: 'Danshui Old Street',
              description: 'Begin coastal traversal.',
              position: const LatLng(25.1700, 121.4400),
            ),
            Waypoint(
              name: 'Fisherman\'s Wharf',
              description: 'Establish forward base.',
              position: const LatLng(25.1800, 121.4200),
            ),
          ],
        ),
      ];
}
