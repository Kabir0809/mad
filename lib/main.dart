import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/add_card_screen.dart';
import 'screens/card_detail_screen.dart';
import 'screens/login_screen.dart';
import 'providers/card_provider.dart';
import 'services/auth_service.dart';
import 'models/loyalty_card.dart';
import 'config/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('Initializing Flutter app');
  
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: firebaseConfig['apiKey']!,
        authDomain: firebaseConfig['authDomain']!,
        projectId: firebaseConfig['projectId']!,
        storageBucket: firebaseConfig['storageBucket']!,
        messagingSenderId: firebaseConfig['messagingSenderId']!,
        appId: firebaseConfig['appId']!,
      ),
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CardProvider(),
      child: MaterialApp(
        title: 'Loyalty Card App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
          useMaterial3: true,
          cardTheme: const CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/add': (context) => const AddCardScreen(),
          '/detail': (context) {
            final card = ModalRoute.of(context)!.settings.arguments as LoyaltyCard;
            return CardDetailScreen(card: card);
          },
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
