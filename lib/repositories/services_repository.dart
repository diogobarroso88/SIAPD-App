import '../models/service.dart';
import '../models/user_service.dart';
import '../objectbox.g.dart';
import '../services/api_service.dart';
import '../services/objectbox_service.dart';

class ServicesRepository {
  final ApiService apiService;
  final ObjectBoxService objectBox;

  ServicesRepository({
    required this.apiService,
    required this.objectBox,
  });

  Future<void> syncServices(String userUuid) async {
    final response = await apiService.dio.get('/services');

    final servicesData = response.data as List<dynamic>;

    for (final item in servicesData) {
      final data = item as Map<String, dynamic>;

      final serviceUuid = data['uuid'] as String? ?? '';

      if (serviceUuid.isEmpty) {
        continue;
      }

      final service = Service(
        uuid: serviceUuid,
        name: data['name'] as String? ?? '',
        slug: data['slug'] as String? ?? '',
        open: data['open'] as bool? ?? false,
      );

      final existingService = objectBox.serviceBox
          .query(Service_.uuid.equals(serviceUuid))
          .build()
          .findFirst();

      if (existingService != null) {
        service.id = existingService.id;
      }

      objectBox.serviceBox.put(service);

      final userService = UserService(
        userUuid: userUuid,
        serviceUuid: serviceUuid,
        subscribed: data['subscribed'] as bool? ?? false,
      );

      final existingUserService = objectBox.userServiceBox
          .query(
        UserService_.userUuid.equals(userUuid) &
        UserService_.serviceUuid.equals(serviceUuid),
      )
          .build()
          .findFirst();

      if (existingUserService != null) {
        userService.id = existingUserService.id;
      }

      objectBox.userServiceBox.put(userService);
    }

  }
}