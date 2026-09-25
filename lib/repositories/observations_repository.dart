import 'dart:io';

import 'package:dio/dio.dart';

import '../models/observation.dart';
import '../models/observation_image.dart';
import '../models/remote_observation.dart';
import '../services/api_service.dart';
import '../services/objectbox_service.dart';
import '../objectbox.g.dart';

class ObservationsRepository {
  final ApiService apiService;
  final ObjectBoxService objectBox;

  ObservationsRepository({
    required this.apiService,
    required this.objectBox,
  });

  Future<void> sendObservation(Observation observation) async {
    try {
      // 1. Obter fotografias da observação
      final images = objectBox.observationImageBox
          .query(
        ObservationImage_.observationId.equals(observation.id),
      )
          .build()
          .find();

      if (images.isEmpty) {
        throw Exception(
          'A observação tem de ter pelo menos uma fotografia.',
        );
      }

      // 2. Criar a observação na API, caso ainda não exista
      if (observation.remoteUuid.isEmpty) {
        await _createRemoteObservation(observation);
      }

      // 3. Enviar fotografias
      await _uploadImages(observation, images);

      // 4. Só aqui consideramos a observação sincronizada
      print('========== OBSERVAÇÃO SINCRONIZADA ==========');
      print('Local ID: ${observation.id}');
      print('Remote UUID: ${observation.remoteUuid}');
      print('Fotografias: ${images.length}');
      print('==============================================');

      for (final image in images) {
        final file = File(image.localPath);

        if (await file.exists()) {
          await file.delete();
        }

        objectBox.observationImageBox.remove(image.id);
      }

      objectBox.observationBox.remove(observation.id);

      print('Observação removida do armazenamento local.');
    } catch (e) {
      observation.syncStatus = 'failed';
      objectBox.observationBox.put(observation);

      print('========== ERRO NA SINCRONIZAÇÃO ==========');
      print('Local ID: ${observation.id}');
      print('Erro: $e');
      print('Estado: ${observation.syncStatus}');
      print('============================================');

      rethrow;
    }
  }

  Future<void> _createRemoteObservation(
      Observation observation,
      ) async {
    final data = <String, dynamic>{
      'title': observation.title,
      'description': observation.description,
      'latitude': observation.latitude,
      'longitude': observation.longitude,
      'geocode': observation.geocode,
      'public': observation.isPublic,
      'user-groups': [
        observation.userGroupUuid,
      ],
    };

    if (observation.serviceSlug == 'vine-phenological-states') {
      data['title-uuid'] = observation.titleUuid;
      data['title'] = observation.titleUuid;
    }

    print('========== CRIAÇÃO DA OBSERVAÇÃO ==========');
    print('Endpoint: /services/${observation.serviceSlug}/observation');
    print('Dados: $data');

    final response = await apiService.dio.post(
      '/services/${observation.serviceSlug}/observation',
      data: data,
    );

    print('Status: ${response.statusCode}');
    print('Resposta: ${response.data}');

    final responseData = response.data as Map<String, dynamic>;
    final remoteUuid = responseData['uuid'] as String?;

    if (remoteUuid == null || remoteUuid.isEmpty) {
      throw Exception(
        'A API não devolveu o UUID da observação.',
      );
    }

    observation.remoteUuid = remoteUuid;
    observation.syncStatus = 'syncing';

    objectBox.observationBox.put(observation);

    print('Remote UUID: $remoteUuid');
  }

  Future<void> _uploadImages(
      Observation observation,
      List<ObservationImage> images,
      ) async {
    final formData = FormData();

    var index = 0;

    for (final image in images) {
      if (image.uploaded) {
        continue;
      }

      final file = File(image.localPath);

      if (!await file.exists()) {
        throw Exception(
          'A fotografia não foi encontrada: ${image.localPath}',
        );
      }

      formData.files.add(
        MapEntry(
          'images[$index]',
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ),
      );

      index++;
    }

    if (index == 0) {
      return;
    }

    print('========== UPLOAD DAS FOTOGRAFIAS ==========');
    print('Remote UUID: ${observation.remoteUuid}');
    print('Fotografias a enviar: $index');

    final response = await apiService.dio.post(
      '/services/${observation.serviceSlug}/observation/${observation.remoteUuid}/images',
      data: formData,
    );

    print('Status imagens: ${response.statusCode}');
    print('Resposta imagens: ${response.data}');

    if (response.statusCode != 200) {
      throw Exception(
        'A API não aceitou as fotografias.',
      );
    }

    final uploadedCount = response.data['images'];

    if (uploadedCount != index) {
      throw Exception(
        'A API não carregou todas as fotografias. '
            'Esperadas: $index, carregadas: $uploadedCount.',
      );
    }

    for (final image in images) {
      if (!image.uploaded) {
        image.uploaded = true;
        objectBox.observationImageBox.put(image);
      }
    }
  }

  Future<List<RemoteObservation>> getRemoteObservations(
      String serviceSlug,
      ) async {
    final response = await apiService.dio.get(
      '/services/$serviceSlug',
    );

    final observations =
        response.data['observations'] as List<dynamic>? ?? [];

    return observations
        .map(
          (json) => RemoteObservation.fromJson(
        json as Map<String, dynamic>,
      ),
    )
        .toList();
  }
}