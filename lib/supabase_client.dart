import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCredentials {
  static const supabaseUrl = 'https://buthvwkrystyweaphqoj.supabase.co';
  static const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ1dGh2d2tyeXN0eXdlYXBocW9qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MDA4MzAsImV4cCI6MjA2OTk3NjgzMH0.rSHiqkKKoHe6eHh4w6_SVXI1u1G24rn8arIuSx3ayjk';
}

final supabase = Supabase.instance.client;
