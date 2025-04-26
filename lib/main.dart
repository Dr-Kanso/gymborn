import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gymborn_app/utils/firebase_config.dart';

import 'providers/auth_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/gym_provider.dart';
import 'providers/location_provider.dart';
import 'frontend_screens/auth/login_screen.dart';
import 'frontend_screens/dashboard/dashboard_screen.dart';
import 'game/ui/game_screen.dart';
import 'frontend_screens/gym/gym_checkin_screen.dart';
import 'frontend_screens/dungeon/dungeon_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initializeFirebase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
        ChangeNotifierProvider(create: (_) => GymProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymBorn',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/gym-checkin': (context) => const GymCheckinScreen(),
        '/game': (context) => const GameScreen(),
        '/dungeon': (context) => const DungeonScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: const Center(child: Text('Page not found')),
          ),
        );
      },
    );
  }
}

// Add a wrapper to handle authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Show a loading indicator while checking auth state
    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Navigate based on authentication state
    if (authProvider.user != null) {
      return const DashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}
