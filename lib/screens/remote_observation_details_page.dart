import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/remote_observation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/service.dart';
import '../models/service_titles.dart';

class RemoteObservationDetailsPage extends StatelessWidget {
  final RemoteObservation observation;
  final Service service;

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

  const RemoteObservationDetailsPage({
    super.key,
    required this.observation,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.details),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          Text(
            l10n.title,
            style: Theme.of(context)
                .textTheme
                .titleMedium,
          ),

          const SizedBox(height: 4),

          Text(
            service.slug == 'vine-phenological-states'
                ? _getPhenologicalStateTranslation(
              observation.title,
              l10n,
            )
                : observation.title,
          ),

          if (observation.description.isNotEmpty) ...[
            const SizedBox(height: 24),

            Text(
              l10n.description,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),

            const SizedBox(height: 6),

            Text(
              observation.description,
            ),
          ],

          const SizedBox(height: 24),

          Text(
            l10n.location,
            style: Theme.of(context)
                .textTheme
                .titleMedium,
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 250,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(
                    observation.latitude,
                    observation.longitude,
                  ),
                  initialZoom: 15,
                  interactionOptions:
                  const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                    'pt.utad.mysense',
                  ),

                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                          observation.latitude,
                          observation.longitude,
                        ),
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.location_on,
                          size: 40,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (observation.geocode.isNotEmpty) ...[
            const SizedBox(height: 10),

            Text(
              observation.geocode,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),
          ],

          const SizedBox(height: 24),

          Text(
            l10n.photos,
            style: Theme.of(context)
                .textTheme
                .titleMedium,
          ),

          const SizedBox(height: 12),

          if (observation.images.isEmpty)
            Text(
              l10n.observationWithoutPhotos,
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: observation.images.length,
              itemBuilder: (context, index) {
                final image =
                observation.images[index];

                return ClipRRect(
                  borderRadius:
                  BorderRadius.circular(12),
                  child: Image.network(
                    image.url,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image,
                        ),
                      );
                    },
                    loadingBuilder:
                        (context, child, progress) {
                      if (progress == null) {
                        return child;
                      }

                      return const Center(
                        child:
                        CircularProgressIndicator(),
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}