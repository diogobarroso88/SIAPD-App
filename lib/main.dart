import 'package:flutter/material.dart';
import 'package:mysense_app_new/providers/auth_provider.dart';
import 'package:mysense_app_new/providers/services_provider.dart';
import 'package:mysense_app_new/repositories/auth_repository.dart';
import 'package:mysense_app_new/repositories/observations_repository.dart';
import 'package:mysense_app_new/repositories/services_repository.dart';
import 'package:mysense_app_new/screens/auth_gate.dart';
import 'package:mysense_app_new/services/api_service.dart';
import 'package:mysense_app_new/services/auth_storage_service.dart';
import 'package:mysense_app_new/services/objectbox_service.dart';
import 'package:provider/provider.dart';
import 'repositories/user_groups_repository.dart';
import 'providers/user_groups_provider.dart';
import 'providers/locale_provider.dart';

import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final objectBox = await ObjectBoxService.create();
  final authStorage = AuthStorageService();


  final apiService = ApiService(
    authStorage: authStorage,
  );

  final authRepository = AuthRepository(
    apiService: apiService,
    authStorage: authStorage,
    objectBox: objectBox,
  );

  final servicesRepository = ServicesRepository(
    apiService: apiService,
    objectBox: objectBox,
  );

  final userGroupsRepository = UserGroupsRepository(
    apiService: apiService,
    objectBox: objectBox,
  );

  final userGroupsProvider = UserGroupsProvider(
    userGroupsRepository: userGroupsRepository,
    objectBox: objectBox,
  );

  final servicesProvider = ServicesProvider(
    servicesRepository: servicesRepository,
    objectBox: objectBox,
  );

  final observationsRepository = ObservationsRepository(
    apiService: apiService,
    objectBox: objectBox,
  );

  final authProvider = AuthProvider(
    authRepository: authRepository,
    servicesProvider: servicesProvider,
    userGroupsProvider: userGroupsProvider,
  );

  final localeProvider = LocaleProvider();

  await localeProvider.loadLocale();

  runApp(
    MultiProvider(
      providers: [
        Provider<ObjectBoxService>.value(
          value: objectBox,
        ),
        Provider<ObservationsRepository>.value(
          value: observationsRepository,
        ),
        Provider<AuthStorageService>.value(
          value: authStorage,
        ),
        Provider<ApiService>.value(
          value: apiService,
        ),
        Provider<AuthRepository>.value(
          value: authRepository,
        ),
        Provider<ServicesRepository>.value(
          value: servicesRepository,
        ),
        Provider<UserGroupsRepository>.value(
          value: userGroupsRepository,
        ),
        ChangeNotifierProvider<UserGroupsProvider>.value(
          value: userGroupsProvider,
        ),
        ChangeNotifierProvider<ServicesProvider>.value(
          value: servicesProvider,
        ),
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
        ),
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
        ),
      ],
      child: const MyApp(),
    ),
  );
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
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AuthGate(),
    );
  }
}