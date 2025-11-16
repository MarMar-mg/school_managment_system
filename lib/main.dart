import 'package:flutter/material.dart';
import 'features/login/presentations/pages/register_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS',
      // Add localization support
      locale: const Locale('fa'), // Set default locale to Persian

      // Add these localization delegates
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Add supported locales
      supportedLocales: const [
        Locale('fa'), // Persian
        Locale('en'), // English
      ],
      scrollBehavior: ScrollConfiguration.of(
        context,
      ).copyWith(scrollbars: false),
      // localizationsDelegates: const [DefaultWidgetsLocalizations.delegate],
      builder: (_, child) => child == null
          ? const SizedBox()
          : Directionality(textDirection: TextDirection.rtl, child: child),
      debugShowCheckedModeBanner: false,
      home: const RegisterPage(),
    );
  }
}

