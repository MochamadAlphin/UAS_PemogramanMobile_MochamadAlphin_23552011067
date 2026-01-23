import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORT PAGES ---
import 'pages/main_pages.dart'; 
import 'pages/login_menu.dart';
import 'pages/register_menu.dart'; 
import 'pages/menu_awal.dart'; 
import 'pages/tiket_menu.dart'; 
import 'pages/promo.dart'; 
import 'pages/profile.dart'; 
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, 
    );
    debugPrint("✅ Firebase Berhasil Terhubung");
  } catch (e) {
    debugPrint("❌ Firebase Error: $e");
  }

  // 2. Inisialisasi Supabase
  try {
    await Supabase.initialize(
      url: 'https://ciwbakzfvccexeldalfx.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNpd2Jha3pmdmNjZXhlbGRhbGZ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg5MDQ3NjUsImV4cCI6MjA4NDQ4MDc2NX0.GBju2kgJ-ppphjoy5uETZ6Qmdi8XZKrY1McquuhZCk4', 
    );
    debugPrint("✅ Supabase Berhasil Terhubung");
  } catch (e) {
    debugPrint("❌ Supabase Error: $e");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Berangkatin',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D2A70),
          primary: const Color(0xFF2D2A70),
          secondary: const Color(0xFFED6B23),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      
      initialRoute: '/', 
      routes: {
        '/': (context) => const MainPagesWidget(), 
        '/loginMenu': (context) => const LoginMenu(),
        '/registerMenu': (context) => const RegisterMenu(), 
        
        // PERBAIKAN: Gunakan '/MenuAwal' (M Besar) agar sama dengan pemanggilan di tombol
        '/MenuAwal': (context) => const MenuAwal(), 
        
        '/tiketMenu': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return TiketMenu(userName: args is String ? args : "PENUMPANG");
        },
        
        '/promo': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return PromoPage(userName: args is String ? args : "PENUMPANG");
        },

        '/profile': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return ProfilePage(userName: args is String ? args : "PENUMPANG");
        },
      },
      
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const MainPagesWidget());
      },
    );
  }
}