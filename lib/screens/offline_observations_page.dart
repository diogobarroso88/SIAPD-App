import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../l10n/app_localizations.dart';
import '../models/service_titles.dart';
import '../repositories/observations_repository.dart';
import '../models/observation.dart';
import '../models/service.dart';
import '../objectbox.g.dart';
import '../services/objectbox_service.dart';
import '../providers/auth_provider.dart';
import 'edit_observation_page.dart';

class OfflineObservationsPage extends StatefulWidget {
  const OfflineObservationsPage({super.key});

  @override
  State<OfflineObservationsPage> createState() =>
      _OfflineObservationsPageState();
}

class _OfflineObservationsPageState
    extends State<OfflineObservationsPage> {
  List<Observation> _observations = [];
  Map<String, Service> _servicesByUuid = {};
  Map<int, int> _imageCountByObservationId = {};
  bool _isSendingAll = false;


  Future<void> _deleteObservation(Observation observation) async {
    final objectBox = context.read<ObjectBoxService>();

    final images = objectBox.observationImageBox
        .query(
      ObservationImage_.observationId.equals(observation.id),
    )
        .build()
        .find();

    for (final image in images) {
      final file = File(image.localPath);

      if (await file.exists()) {
        await file.delete();
      }

      objectBox.observationImageBox.remove(image.id);
    }

    objectBox.observationBox.remove(observation.id);

    _loadObservations();
  }

  Future<void> _sendObservation(Observation observation) async {
    final repository = context.read<ObservationsRepository>();
    final l10n = AppLocalizations.of(context)!;

    try {
      await repository.sendObservation(observation);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.observationSentSuccess),
        ),
      );

      _loadObservations();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.observationSendError,
          ),
        ),
      );
    }
  }

  Future<void> _sendAllObservations() async {
    if (_isSendingAll) {
      return;
    }

    final objectBox = context.read<ObjectBoxService>();
    final authProvider = context.read<AuthProvider>();
    final repository = context.read<ObservationsRepository>();
    final l10n = AppLocalizations.of(context)!;

    final user = authProvider.user;

    if (user == null) {
      return;
    }

    final observations = objectBox.observationBox
        .query(
      Observation_.userUuid.equals(user.uuid),
    )
        .build()
        .find();

    if (observations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noObservationsToSend),
        ),
      );
      return;
    }

    setState(() {
      _isSendingAll = true;
    });

    var sentCount = 0;
    var failedCount = 0;

    for (final observation in observations) {
      try {
        await repository.sendObservation(observation);
        sentCount++;
      } catch (e) {
        failedCount++;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSendingAll = false;
    });

    _loadObservations();

    if (failedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$sentCount ${sentCount == 1 ? l10n.observationSent : l10n.sentObservations} ${l10n.success}.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$sentCount ${l10n.sentSuccessfully} '
                '$failedCount ${failedCount == 1 ? l10n.failed : l10n.failedPlural}.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmDelete(Observation observation) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteObservation),
          content: Text(
            l10n.confirmDeleteObservation,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteObservation(observation);
    }
  }

  void _showObservationMenu(Observation observation) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.send),
                title: Text(l10n.send),
                onTap: () {
                  Navigator.pop(context);
                  _sendObservation(observation);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(l10n.edit),
                onTap: () async {
                  Navigator.pop(context);

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditObservationPage(
                        observation: observation,
                      ),
                    ),
                  );

                  if (result == true) {
                    _loadObservations();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: Text(l10n.delete),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(observation);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getServiceName(
      Service service,
      AppLocalizations l10n,
      ) {
    switch (service.name) {
      case 'Registo de estados fenológicos da videira':
        return l10n.serviceVinePhenologicalStates;

      case 'Identificação de castas de videira':
        return l10n.serviceVineVarietiesIdentification;

      case 'Comunidade da Oliveira':
        return l10n.serviceOliveCommunity;

      case 'Contagem de percevejos do arroz':
        return l10n.serviceRiceStinkBugCounting;

      case 'Flora Digital de Portugal':
        return l10n.serviceDigitalFloraPortugal;

      case 'Identificação de pragas perenes':
        return l10n.servicePerennialPestIdentification;

      case 'Machine Learning':
        return l10n.serviceMachineLearning;

      case 'Observação biológica de linhas produtivas':
        return l10n.serviceBiologicalObservationProductiveRows;

      case 'Registo da brusone do arroz':
        return l10n.serviceRiceBlastRecord;

      case 'Registo da presença de Cerambyx':
        return l10n.serviceCerambyxPresenceRecord;

      case 'Registo da presença de NMP':
        return l10n.serviceNmpPresenceRecord;

      case 'Infestações de gafanhotos':
        return l10n.serviceLocustInfestationsRecord;

      case 'Registo da pudenta do arroz':
        return l10n.serviceRicePudentaRecord;

      case 'Estados fenológicos da macieira':
        return l10n.serviceApplePhenologicalStatesRecord;

      case 'Grupo de testes internos':
        return l10n.serviceInternalTestsGroup;

      case 'Identificação de doenças da videira':
        return l10n.serviceVineDiseaseIdentification;

      default:
        return service.name;
    }
  }

  String _getPhenologicalStateTranslation(
      String state,
      AppLocalizations l10n,
      ) {
    final normalizedState = state
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase();

    final entry = ServiceTitles.vinePhenologicalStateUuids.entries
        .cast<MapEntry<String, String>?>()
        .firstWhere(
          (entry) => entry!.key.toLowerCase() == normalizedState,
      orElse: () => null,
    );

    final uuid = entry?.value;

    switch (uuid) {
      case 'a_winter_bud':
        return l10n.phenologyAWinterBud;
      case 'b_woolly_bud':
        return l10n.phenologyBWoollyBud;
      case 'c_bud_break':
        return l10n.phenologyCBudBreak;
      case 'd_leaf_emergence':
        return l10n.phenologyDLeafEmergence;
      case 'e_leaves_separated':
        return l10n.phenologyELeavesSeparated;
      case 'f_inflorescences_visible':
        return l10n.phenologyFInflorescencesVisible;
      case 'g_inflorescences_separated':
        return l10n.phenologyGInflorescencesSeparated;
      case 'h_flowers_separated':
        return l10n.phenologyHFlowersSeparated;
      case 'i_bloom':
        return l10n.phenologyIBloom;
      case 'j_fruit_set':
        return l10n.phenologyJFruitSet;
      case 'k_berries_pea_size':
        return l10n.phenologyKBerriesPeaSize;
      case 'l_berries_touching':
        return l10n.phenologyLBerriesTouching;
      case 'm_veraison':
        return l10n.phenologyMVeraison;
      case 'n_maturity':
        return l10n.phenologyNMaturity;
      case 'o_cane_maturation':
        return l10n.phenologyOCaneMaturation;
      case 'p_leaf_fall':
        return l10n.phenologyPLeafFall;
      default:
        return state;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadObservations();
  }

  void _loadObservations() {
    final objectBox = context.read<ObjectBoxService>();
    final authProvider = context.read<AuthProvider>();

    final user = authProvider.user;

    if (user == null) {
      return;
    }

    final observations = objectBox.observationBox
        .query(
      Observation_.userUuid.equals(user.uuid),
    )
        .build()
        .find();

    final services = objectBox.serviceBox.getAll();

    final servicesByUuid = <String, Service>{
      for (final service in services) service.uuid: service,
    };

    final imageCountByObservationId = <int, int>{};

    for (final observation in observations) {
      final images = objectBox.observationImageBox
          .query(
        ObservationImage_.observationId.equals(
          observation.id,
        ),
      )
          .build()
          .find();

      imageCountByObservationId[observation.id] = images.length;
    }

    observations.sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    setState(() {
      _observations = observations;
      _servicesByUuid = servicesByUuid;
      _imageCountByObservationId = imageCountByObservationId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_observations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 120),
        child: Center(
          child: Column(
            children: [
              Image.asset(
                'assets/images/logo_letras.png',
                width: 380,
              ),
              const SizedBox(height: 50),
              Text(
                l10n.noOfflineObservations,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isSendingAll
                ? null
                : _sendAllObservations,
            icon: _isSendingAll
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.cloud_upload),
            label: Text(
              _isSendingAll
                  ? l10n.sendingObservations
                  : l10n.sendAllObservations,
            ),
          ),
        ),

        const SizedBox(height: 16),

        ..._observations.map((observation) {
          final service =
          _servicesByUuid[observation.serviceUuid];

          final imageCount =
              _imageCountByObservationId[observation.id] ?? 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              onTap: () => _showObservationMenu(observation),
              title: Text(
                observation.serviceSlug == 'vine-phenological-states'
                    ? _getPhenologicalStateTranslation(
                  observation.title,
                  l10n,
                )
                    : observation.title.isNotEmpty
                    ? observation.title
                    : l10n.untitled,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    service != null
                        ? _getServiceName(service, l10n)
                        : observation.serviceSlug,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(observation.createdAt)} · '
                        '$imageCount '
                        '${imageCount == 1 ? l10n.photo : l10n.photos}',
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}