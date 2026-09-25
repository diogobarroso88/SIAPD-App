import 'package:dio/dio.dart';

import '../models/user.dart';
import '../objectbox.g.dart';
import '../services/api_service.dart';
import '../services/auth_storage_service.dart';
import '../services/objectbox_service.dart';

class AuthRepository {
  final ApiService apiService;
  final AuthStorageService authStorage;
  final ObjectBoxService objectBox;

  AuthRepository({
    required this.apiService,
    required this.authStorage,
    required this.objectBox,
  });

  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Fazer login e obter o token
      final loginResponse = await apiService.dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final token = loginResponse.data['token'] as String?;

      if (token == null || token.isEmpty) {
        throw Exception('A API não devolveu um token.');
      }

      // 2. Temporariamente precisamos do token para pedir /user.
      //
      // Como ainda não sabemos o UUID do utilizador,
      // fazemos o request diretamente com este token.
      final userResponse = await apiService.dio.get(
        '/user',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = userResponse.data as Map<String, dynamic>;

// 3. Criar o nosso User local
      final user = User(
        uuid: data['uuid'] as String? ?? '',
        name: data['name'] as String? ?? '',
        username: data['username'] as String? ?? '',
        email: data['email'] as String? ?? '',
        avatarUrl: data['avatar'] as String? ?? '',
      );

      if (user.uuid.isEmpty) {
        throw Exception('A API não devolveu o UUID do utilizador.');
      }

      // 4. Guardar token associado a este utilizador
      await authStorage.saveToken(
        user.uuid,
        token,
      );

      // 5. Definir este utilizador como o utilizador activo
      await authStorage.setActiveUserUuid(
        user.uuid,
      );

      // 6. Guardar/actualizar o utilizador no ObjectBox
      final existingUser = objectBox.userBox
          .query(User_.uuid.equals(user.uuid))
          .build()
          .findFirst();

      if (existingUser != null) {
        user.id = existingUser.id;
      }

      objectBox.userBox.put(
        user,
        mode: PutMode.put,
      );

      return user;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            'Não foi possível iniciar sessão.',
      );
    }
  }

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    await apiService.dio.post(
      '/register',
      data: {
        'name': name,
        'email': email,
        'username': username,
        'password': password,
      },
    );
  }

  Future<User?> checkSession() async {
    final activeUserUuid = await authStorage.getActiveUserUuid();

    if (activeUserUuid == null || activeUserUuid.isEmpty) {
      return null;
    }

    final token = await authStorage.getToken(activeUserUuid);

    if (token == null || token.isEmpty) {
      return null;
    }

    final localUser = objectBox.userBox
        .query(User_.uuid.equals(activeUserUuid))
        .build()
        .findFirst();

    return localUser;
  }

  Future<void> logout() async {
    final activeUserUuid = await authStorage.getActiveUserUuid();

    if (activeUserUuid != null && activeUserUuid.isNotEmpty) {
      await authStorage.removeToken(activeUserUuid);
    }

    await authStorage.clearActiveUser();
  }
}