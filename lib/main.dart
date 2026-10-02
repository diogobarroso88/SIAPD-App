import 'package:flutter/material.dart';
import 'package:mysense_app_new/screens/auth_gate.dart';
import 'package:provider/provider.dart';
import 'app_bootstrap.dart';
import 'providers/locale_provider.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const AppBootstrap());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mySense',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      locale: context.watch<LocaleProvider>().locale,
      localizationsDelegates:
      AppLocalizations.localizationsDelegates,
      supportedLocales:
      AppLocalizations.supportedLocales,
      home: const AuthGate(),
    );
  }
}