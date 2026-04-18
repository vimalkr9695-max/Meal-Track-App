import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0F0F0E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4A853),
          surface: Color(0xFF1A1A18),
        ),
        textTheme: GoogleFonts.dmSansTextTheme().apply(
          bodyColor: const Color(0xFFF0EDE6),
          displayColor: const Color(0xFFF0EDE6),
        ),
      ),
      // StreamBuilder listens to auth state
      // Auto sends to home if logged in, login if not
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _SplashScreen();
          }
          if (snapshot.hasData) {
            return const HomePage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFD4A853).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFFD4A853).withOpacity(0.4)),
              ),
              child: const Icon(Icons.restaurant_outlined,
                  color: Color(0xFFD4A853), size: 30),
            ),
            const SizedBox(height: 16),
            Text('Meal Tracker',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF0EDE6),
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Color(0xFFD4A853),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}