import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:renewa/screens/green_campigns.dart';
import 'package:renewa/screens/register_page.dart';
import 'package:renewa/screens/splash.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

final theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light, 
    seedColor: const Color.fromARGB(55, 4, 13, 11),
  ),
  textTheme: GoogleFonts.judsonTextTheme(),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Renewa',
      theme: theme,
      home: const AuthStateScreen(),
    );
  }
}

class AuthStateScreen extends StatelessWidget {
  const AuthStateScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } 
        if (snapshot.hasData) {
          return const GreenCampignsScreen();
        } 
          return const RegistrationScreen();
        
      },
    );
  }
}