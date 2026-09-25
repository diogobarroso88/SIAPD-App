import 'package:dio/dio.dart';
import 'auth_storage_service.dart';

class ApiService {
  static const String baseUrl = 'https://mysenseapi.utad.pt/api';

  final AuthStorageService authStorage;

  late final Dio dio;

  ApiService({
    required this.authStorage,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final activeUserUuid =
          await authStorage.getActiveUserUuid();

          if (activeUserUuid != null) {
            final token =
            await authStorage.getToken(activeUserUuid);

            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          handler.next(options);
        },
      ),
    );
  }
}