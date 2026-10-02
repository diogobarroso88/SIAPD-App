import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/services_provider.dart';
import 'providers/user_groups_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/observations_repository.dart';
import 'repositories/services_repository.dart';
import 'repositories/user_groups_repository.dart';
import 'services/api_service.dart';
import 'services/auth_storage_service.dart';
import 'services/objectbox_service.dart';
import 'services/profile_image_service.dart';
import 'screens/auth_gate.dart';
import 'screens/splash_page.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  bool _isReady = false;



  late ObjectBoxService objectBox;
  late AuthStorageService authStorage;
  late ApiService apiService;
  late ProfileImageService profileImageService;
  late AuthRepository authRepository;
  late ServicesRepository servicesRepository;
  late UserGroupsRepository userGroupsRepository;
  late UserGroupsProvider userGroupsProvider;
  late ServicesProvider servicesProvider;
  late ObservationsRepository observationsRepository;
  late AuthProvider authProvider;
  late LocaleProvider localeProvider;

  @override
  void initState() {
    super.initState();

    localeProvider = LocaleProvider();

    _initialize();
  }

  Future<void> _initialize() async {
    objectBox = await ObjectBoxService.create();

    authStorage = AuthStorageService();

    apiService = ApiService(
      authStorage: authStorage,
    );

    profileImageService = ProfileImageService(
      apiService.dio,
    );

    authRepository = AuthRepository(
      apiService: apiService,
      authStorage: authStorage,
      objectBox: objectBox,
      profileImageService: profileImageService,
    );

    servicesRepository = ServicesRepository(
      apiService: apiService,
      objectBox: objectBox,
    );

    userGroupsRepository = UserGroupsRepository(
      apiService: apiService,
      objectBox: objectBox,
    );

    userGroupsProvider = UserGroupsProvider(
      userGroupsRepository: userGroupsRepository,
      objectBox: objectBox,
    );

    servicesProvider = ServicesProvider(
      servicesRepository: servicesRepository,
      objectBox: objectBox,
    );

    observationsRepository = ObservationsRepository(
      apiService: apiService,
      objectBox: objectBox,
    );

    authProvider = AuthProvider(
      authRepository: authRepository,
      servicesProvider: servicesProvider,
      userGroupsProvider: userGroupsProvider,
    );



    await localeProvider.loadLocale();

    if (!mounted) return;

    setState(() {
      _isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashPage(),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: localeProvider,
        ),

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
      ],
      child: const MyApp(),
    );
  }
}