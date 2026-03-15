import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'app/app_state.dart';
import 'app/app_providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ...AppProviders.all(),
      ],
      child: const DariBudgetApp(),
    ),
  );
}

class DariBudgetApp extends StatelessWidget {
  const DariBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'DariBudget',
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
      locale: appState.locale,
      supportedLocales: AppState.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
