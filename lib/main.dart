import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/trip_provider.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // keep it portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
      ],
      child: MaterialApp(
        title: 'Smart Travel Planner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
