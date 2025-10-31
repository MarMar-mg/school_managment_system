import 'package:flutter/material.dart';
import 'features/login/presentations/pages/register_page.dart';
import 'package:provider/provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/services/api_service.dart';

void main() async {
  try {
    final news = await ApiService.getNews();
    print(news);
  } catch (e) {
    print(e);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS',
      scrollBehavior: ScrollConfiguration.of(
        context,
      ).copyWith(scrollbars: false),
      localizationsDelegates: const [DefaultWidgetsLocalizations.delegate],
      builder: (_, child) => child == null
          ? const SizedBox()
          : Directionality(textDirection: TextDirection.rtl, child: child),
      debugShowCheckedModeBanner: false,
      home: const RegisterPage(),
    );
  }
}
