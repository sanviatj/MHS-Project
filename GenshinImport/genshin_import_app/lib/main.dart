import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/admin_form_screen.dart';
import 'screens/admin_dashboard_screen.dart'; 
import 'screens/user_home_screen.dart'; 
import 'screens/product_detail_screen.dart';
import 'screens/purchase_history_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Genshin Import',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFECC065), 
        scaffoldBackgroundColor: const Color(0xFF0C111D), 
        
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
          titleLarge: TextStyle(color: Color(0xFFECC065), fontWeight: FontWeight.bold, fontSize: 22),
        ),
        
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Color(0xFFECC065)),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFECC065), width: 2),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
          ),
          errorStyle: TextStyle(color: Colors.redAccent),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFECC065),
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),

      home: const LoginScreen(),

     routes: {
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/admin-dashboard': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return AdminDashboardScreen(token: args?['token'] ?? '');
  },
  '/user-home': (context) => const UserHomeScreen(),
  '/product-detail': (context) => const ProductDetailScreen(),
  '/admin-form': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return AdminFormScreen(weapon: args?['weapon'], token: args?['token'] ?? '');
  },
},
    );
  }
}