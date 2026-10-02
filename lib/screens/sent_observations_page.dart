import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../l10n/app_localizations.dart';
import '../models/remote_observation.dart';
import '../models/service.dart';
import '../models/service_titles.dart';
import '../providers/services_provider.dart';
import '../repositories/observations_repository.dart';
import '../screens/remote_observation_details_page.dart';

class SentObservationsPage extends StatefulWidget {
  const SentObservationsPage({super.key});

  @override
  State<SentObservationsPage> createState() =>
      _SentObservationsPageState();
}

class _SentObservationsPageState
    extends State<SentObservationsPage> {

  Service? _selectedService;

  List<RemoteObservation> _observations = [];

  bool _isLoading = false;
  bool _showMap = false;
  String? _error;

  void _showMarkerDetails(RemoteObservation observation) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  observation.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge,
                ),

                const SizedBox(height: 8),

                Text(
                  '${observation.images.length} '
                      '${observation.images.length == 1 ? l10n.photo : l10n.photos}',
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _openDetails(observation, _selectedService!);
                    },
                    icon: const Icon(Icons.info_outline),
                    label: Text(l10n.viewDetails),
                  ),
                ),
              ],
            ),
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

      case 'Comunidade do Olival':
        return l10n.serviceOliveCommunity;

      case 'Contagem automática do Percevejo-do-arroz':
        return l10n.serviceRiceStinkBugCounting;

      case 'Flora digital de Portugal':
        return l10n.serviceDigitalFloraPortugal;

      case 'Identificação de pragas e doenças em espécies perenes':
        return l10n.servicePerennialPestIdentification;

      case 'Machine Learning':
        return l10n.serviceMachineLearning;

      case 'Observação biológica em fileiras produtivas':
        return l10n.serviceBiologicalObservationProductiveRows;

      case 'Registo da periculariosis do arroz':
        return l10n.serviceRiceBlastRecord;

      case 'Registo da presença de Cerambyx':
        return l10n.serviceCerambyxPresenceRecord;

      case 'Registo da presença de NMP':
        return l10n.serviceNmpPresenceRecord;

      case 'Registo da presença de pragas de gafanhoto':
        return l10n.serviceLocustInfestationsRecord;

      case 'Registo da pudenta do arroz':
        return l10n.serviceRicePudentaRecord;

      case 'Registo dos estados fenológicos da macieira':
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

    debugPrint('Título recebido: "$state"');
    debugPrint('Título normalizado: "$normalizedState"');
    debugPrint('UUID encontrado: "$uuid"');

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

  void _openDetails(
      RemoteObservation observation,
      Service service,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RemoteObservationDetailsPage(
          observation: observation,
          service: service,
        ),
      ),
    );
  }


  Future<void> _loadObservations() async {
    if (_selectedService == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository =
      context.read<ObservationsRepository>();

      final observations =
      await repository.getRemoteObservations(
        _selectedService!.slug,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _observations = observations;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _observations = [];
        _error =
        'Não foi possível carregar as observações.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final services =
          context.read<ServicesProvider>().subscribedServices;

      if (services.isNotEmpty && mounted) {
        setState(() {
          _selectedService = services.first;
        });

        _loadObservations();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final services =
        context.watch<ServicesProvider>()
            .subscribedServices;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            DropdownButtonFormField<Service>(
              initialValue: _selectedService,
              decoration: InputDecoration(
                labelText: l10n.chooseService,
                border: const OutlineInputBorder(),
              ),
              items: services.map((service) {
                return DropdownMenuItem<Service>(
                  value: service,
                  child: Text(_getServiceName(service, l10n)),
                );
              }).toList(),
              onChanged: (service) {
                setState(() {
                  _selectedService = service;
                  _observations = [];
                  _error = null;
                });

                if (service != null) {
                  _loadObservations();
                }
              },
            ),

            const SizedBox(height: 16),

            if (_selectedService != null)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _showMap = false;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.list,
                                color: !_showMap
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.list,
                                style: TextStyle(
                                  color: !_showMap
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                  fontWeight: !_showMap
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Container(
                      width: 1,
                      height: 35,
                      color: Theme.of(context).colorScheme.outline,
                    ),

                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _showMap = true;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map,
                                color: _showMap
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.map,
                                style: TextStyle(
                                  color: _showMap
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                  fontWeight: _showMap
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Text(_error!),
                ),
              )
            else if (_selectedService == null)
                Expanded(
                  child: Center(
                    child: Text(
                      l10n.selectService,
                    ),
                  ),
                )
              else if (_observations.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        l10n.noObservations,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: _showMap
                        ? FlutterMap(
                      options: MapOptions(
                        initialCenter: _observations.isNotEmpty
                            ? LatLng(
                          _observations.first.latitude,
                          _observations.first.longitude,
                        )
                            : const LatLng(41.295, -7.73),
                        initialZoom: 13,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                          'pt.utad.mysense',
                        ),

                        MarkerLayer(
                          markers: _observations.map((observation) {
                            return Marker(
                              point: LatLng(
                                observation.latitude,
                                observation.longitude,
                              ),
                              width: 50,
                              height: 50,
                              child: GestureDetector(
                                onTap: () {
                                  _showMarkerDetails(observation);
                                },
                                child: const Icon(
                                  Icons.location_on,
                                  size: 40,
                                  color: Colors.blue,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    )
                        : ListView.builder(
                      itemCount: _observations.length,
                      itemBuilder: (context, index) {
                        final observation =
                        _observations[index];

                        final photoCount =
                            observation.images.length;

                        return Card(
                          child: ListTile(
                            title: Text(
                              _selectedService?.slug == 'vine-phenological-states'
                                  ? _getPhenologicalStateTranslation(
                                observation.title,
                                l10n,
                              )
                                  : observation.title,
                            ),
                            subtitle: Text(
                              '$photoCount '
                                  '${photoCount == 1 ? l10n.photo : l10n.photos}',
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                            ),
                            onTap: () {
                              _openDetails(observation, _selectedService!);
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}