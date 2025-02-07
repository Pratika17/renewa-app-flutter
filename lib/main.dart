import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:renewa/providers.dart';
import 'package:renewa/screens/green_campigns.dart';
import 'package:renewa/screens/newFeatures/onboarding_screen.dart';
import 'package:renewa/screens/register_page.dart';
import 'package:renewa/screens/splash.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

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
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends  ConsumerStatefulWidget {
  const MyApp({super.key});

    @override
  ConsumerState<MyApp> createState() {
    return _MyAppState();
  }
}
class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Renewa',
      theme: theme,
      home: AuthStateScreen(),
    );
  }
}

class AuthStateScreen extends ConsumerStatefulWidget {
  AuthStateScreen({super.key});
  

    @override
  ConsumerState<AuthStateScreen> createState() {
    return _AuthStateScreenState();
  }
}
class _AuthStateScreenState extends ConsumerState<AuthStateScreen> {
  
  @override
  Widget build(BuildContext context) {
    final isOnboardingDone = ref.watch(onboardingProvider);
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } 
        if (snapshot.hasData) {
          return const GreenCampignsScreen();
        } 
          return isOnboardingDone? const RegistrationScreen():const OnboardingPage1();
        
      },
    );
  }
}