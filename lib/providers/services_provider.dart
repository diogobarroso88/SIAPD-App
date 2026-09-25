import 'package:flutter/foundation.dart';

import '../models/service.dart';
import '../repositories/services_repository.dart';
import '../services/auth_storage_service.dart';
import '../services/objectbox_service.dart';
import '../objectbox.g.dart';

class ServicesProvider extends ChangeNotifier {
  final ServicesRepository servicesRepository;
  final ObjectBoxService objectBox;

  ServicesProvider({
    required this.servicesRepository,
    required this.objectBox,
  });

  List<Service> _services = [];
  List<Service> _subscribedServices = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<Service> get services => _services;
  List<Service> get subscribedServices => _subscribedServices;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadServices(String userUuid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _services = objectBox.serviceBox.getAll();

      _subscribedServices = _services.where((service) {
        final userService = objectBox.userServiceBox
            .query(
          UserService_.userUuid.equals(userUuid) &
          UserService_.serviceUuid.equals(service.uuid),
        )
            .build()
            .findFirst();

        return userService?.subscribed ?? false;
      }).toList();
    } catch (e) {
      _errorMessage = 'Não foi possível carregar os serviços.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncServices(String userUuid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await servicesRepository.syncServices(userUuid);
      await loadServices(userUuid);
    } catch (e) {
      _errorMessage = 'Não foi possível sincronizar os serviços.';
      _isLoading = false;
      notifyListeners();
    }
  }
}