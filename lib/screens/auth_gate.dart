import 'package:flutter/material.dart';
import 'package:mysense_app_new/screens/splash_page.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import 'login_page.dart';
import 'navigation_home_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context.read<LocaleProvider>().loadLocale();
      await context.read<AuthProvider>().checkSession();

      if (mounted) {
        setState(() {
          _checkingSession = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (_checkingSession || authProvider.isLoading) {
      return const SplashPage();
    }

    if (authProvider.isAuthenticated) {
      return const NavigationHomeScreen();
    }

    return const LoginPage();
  }
}