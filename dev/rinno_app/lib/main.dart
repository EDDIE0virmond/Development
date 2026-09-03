// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/providers/auth_provider.dart';
import 'core/network/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Rinnovare App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF2E7D32),
          scaffoldBackgroundColor: const Color(0xFFF5F9F0),
          fontFamily: GoogleFonts.inter().fontFamily,
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2E7D32),
            secondary: Color(0xFF66BB6A),
            tertiary: Color(0xFF1B5E20),
          ),
        ),
        initialRoute: AppRoutes.loadingEntry,
        onGenerateRoute: (settings) {
          final route = AppRoutes.routes[settings.name];
          if (route != null) {
            return MaterialPageRoute(builder: route);
          }
          return null;
        },
      ),
    );
  }
}