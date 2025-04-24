import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'themes/theme.dart';
import 'screens/stats/stats_screen.dart';
import 'screens/gym_checkin/gym_checkin_screen.dart';
import 'screens/dungeon/dungeon_screen.dart';
import 'screens/raids/raids_screen.dart';
import 'screens/marketplace/marketplace_screen.dart';
import 'screens/synergy_cards/synergy_cards_screen.dart';
import 'screens/skills/skills_screen.dart';
import 'screens/gym_fortress/gym_fortress_screen.dart';
import 'screens/profile/profile_screen.dart';

class GymBornApp extends StatelessWidget {
  const GymBornApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gymborn',
      theme: gymBornTheme,
      home: Consumer<AuthProvider>(
        builder: (ctx, authProvider, _) {
          return authProvider.isAuth
              ? const DashboardScreen()
              : const AuthScreen();
        },
      ),
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/stats': (context) => const StatsScreen(),
        '/gym-checkin': (context) => const GymCheckinScreen(),
        '/dungeon': (context) => const DungeonScreen(),
        '/raids': (context) => const RaidsScreen(),
        '/marketplace': (context) => const MarketplaceScreen(),
        '/synergy-cards': (context) => const SynergyCardsScreen(),
        '/skills': (context) => const SkillsScreen(),
        '/gym-fortress': (context) => const GymFortressScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

// Import all screens for route definitions
