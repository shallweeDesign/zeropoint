import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/mission_provider.dart';
import 'screens/map_screen.dart';
import 'screens/achievements_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ZeroPointApp());
}

class ZeroPointApp extends StatelessWidget {
  const ZeroPointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MissionProvider()),
      ],
      child: MaterialApp(
        title: '0POINT',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        initialRoute: '/',
        routes: {
          '/': (_) => const MapScreen(),
          '/achievements': (_) => const AchievementsScreen(),
        },
      ),
    );
  }
}
