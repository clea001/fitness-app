import 'package:flutter/material.dart';
import 'screens/main_scaffold.dart';
import 'screens/api_settings_screen.dart';
import 'screens/fitness_input_screen.dart';
import 'screens/diet_input_screen.dart';
import 'screens/fitness_result_screen.dart';
import 'screens/diet_result_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI 健身助手',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainScaffold(),
      routes: {
        '/settings': (_) => const ApiSettingsScreen(),
        '/fitness-input': (_) => const FitnessInputScreen(),
        '/diet-input': (_) => const DietInputScreen(),
        '/fitness-result': (_) => const FitnessResultScreen(),
        '/diet-result': (_) => const DietResultScreen(),
        '/calendar': (_) => const CalendarScreen(),
      },
    );
  }
}
