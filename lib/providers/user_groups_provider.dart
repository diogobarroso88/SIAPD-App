import 'package:flutter/foundation.dart';

import '../models/user_group.dart';
import '../objectbox.g.dart';
import '../repositories/user_groups_repository.dart';
import '../services/objectbox_service.dart';

class UserGroupsProvider extends ChangeNotifier {
  final UserGroupsRepository userGroupsRepository;
  final ObjectBoxService objectBox;

  UserGroupsProvider({
    required this.userGroupsRepository,
    required this.objectBox,
  });

  List<UserGroup> _groups = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<UserGroup> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadGroups(String userUuid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _groups = objectBox.userGroupBox
          .query(
        UserGroup_.userUuid.equals(userUuid),
      )
          .build()
          .find();
    } catch (e) {
      _errorMessage = 'Não foi possível carregar os grupos.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncGroups(String userUuid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await userGroupsRepository.syncUserGroups(userUuid);
      await loadGroups(userUuid);
    } catch (e) {
      _errorMessage = 'Não foi possível sincronizar os grupos.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}