import 'package:flutter/foundation.dart';
import 'package:mysense_app_new/providers/user_groups_provider.dart';

import '../models/user.dart';
import '../repositories/auth_repository.dart';
import 'services_provider.dart';


class AuthProvider extends ChangeNotifier {

  AuthProvider({
    required this.authRepository,
    required this.servicesProvider,
    required this.userGroupsProvider,
  });

  final AuthRepository authRepository;
  final ServicesProvider servicesProvider;
  final UserGroupsProvider userGroupsProvider;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _user != null;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await authRepository.login(
        email: email,
        password: password,
      );

      await servicesProvider.syncServices(_user!.uuid);
      await userGroupsProvider.syncGroups(_user!.uuid);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await authRepository.checkSession();

      if (_user != null) {
        await servicesProvider.loadServices(_user!.uuid);
        await userGroupsProvider.loadGroups(_user!.uuid);
      }
    } catch (_) {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await authRepository.register(
        name: name,
        username: username,
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}