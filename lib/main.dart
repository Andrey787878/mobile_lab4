import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/calendar_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const CalendarApp());

class CalendarApp extends StatelessWidget {
  const CalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Календарь',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ru'),
      supportedLocales: const [Locale('ru')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: calendarTheme(),
      builder: (context, child) => ColoredBox(
        color: AppColors.surface,
        child: Center(
          child: SizedBox(
            width: 420,
            child: LayoutBuilder(
              builder: (context, constraints) => MediaQuery(
                data: MediaQuery.of(context).copyWith(size: constraints.biggest),
                child: child!,
              ),
            ),
          ),
        ),
      ),
      home: const CalendarScreen(),
    );
  }
}
