import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/remote_observation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RemoteObservationDetailsPage extends StatelessWidget {
  final RemoteObservation observation;

  const RemoteObservationDetailsPage({
    super.key,
    required this.observation,
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
            observation.title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall,
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