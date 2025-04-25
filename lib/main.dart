import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/gym_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/game/game_screen.dart';
import 'screens/gym/gym_checkin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
        ChangeNotifierProvider(create: (_) => GymProvider()),
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
