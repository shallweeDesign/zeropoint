import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

enum MissionStatus { active, completed, failed }
enum MissionType { explore, collect, reach, survive }

class Waypoint {
  final String id;
  final String name;
  final String description;
  final LatLng position;
  bool isCompleted;

  Waypoint({
    String? id,
    required this.name,
    required this.description,
    required this.position,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  Waypoint copyWith({bool? isCompleted}) => Waypoint(
        id: id,
        name: name,
        description: description,
        position: position,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'lat': position.latitude,
        'lng': position.longitude,
        'isCompleted': isCompleted,
      };

  factory Waypoint.fromJson(Map<String, dynamic> j) => Waypoint(
        id: j['id'],
        name: j['name'],
        description: j['description'],
        position: LatLng(j['lat'], j['lng']),
        isCompleted: j['isCompleted'] ?? false,
      );
}

class Mission {
  final String id;
  final String title;
  final String briefing;
  final MissionType type;
  MissionStatus status;
  final List<Waypoint> waypoints;
  final DateTime createdAt;
  final String createdBy;
  final List<String> squadIds;

  Mission({
    String? id,
    required this.title,
    required this.briefing,
    required this.type,
    this.status = MissionStatus.active,
    required this.waypoints,
    DateTime? createdAt,
    required this.createdBy,
    List<String>? squadIds,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        squadIds = squadIds ?? [];

  int get completedCount => waypoints.where((w) => w.isCompleted).length;
  double get progress => waypoints.isEmpty ? 0 : completedCount / waypoints.length;
  bool get isFullyComplete => waypoints.isNotEmpty && completedCount == waypoints.length;

  LatLng get center {
    if (waypoints.isEmpty) return const LatLng(25.0330, 121.5654);
    final lat = waypoints.map((w) => w.position.latitude).reduce((a, b) => a + b) / waypoints.length;
    final lng = waypoints.map((w) => w.position.longitude).reduce((a, b) => a + b) / waypoints.length;
    return LatLng(lat, lng);
  }
}
