import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // necessário para async
  await Supabase.initialize(
    url: 'https://buthvwkrystyweaphqoj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ1dGh2d2tyeXN0eXdlYXBocW9qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MDA4MzAsImV4cCI6MjA2OTk3NjgzMH0.rSHiqkKKoHe6eHh4w6_SVXI1u1G24rn8arIuSx3ayjk',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gerenciador de Contatos',
      initialRoute: '/',
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
