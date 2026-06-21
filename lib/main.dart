import 'package:field_star/navigation/nav.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://pspegmbnkmaiwaryafby.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBzcGVnbWJua21haXdhcnlhZmJ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA4OTA3NTYsImV4cCI6MjA5NjQ2Njc1Nn0.A6DbjdHbPd2lnlEYLjPGEGtG8IubIynQCAVkf31t534',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
   return MaterialApp.router(
      title: 'Field Star',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

