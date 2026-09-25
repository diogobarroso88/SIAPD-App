class RemoteObservation {
  final String uuid;
  final String title;
  final String description;
  final String geocode;
  final double latitude;
  final double longitude;
  final List<RemoteObservationImage> images;

  RemoteObservation({
    required this.uuid,
    required this.title,
    required this.description,
    required this.geocode,
    required this.latitude,
    required this.longitude,
    required this.images,
  });

  factory RemoteObservation.fromJson(
      Map<String, dynamic> json,
      ) {
    return RemoteObservation(
      uuid: json['uuid'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      geocode: json['geocode'] ?? '',
      latitude: double.tryParse(
        json['latitude']?.toString() ?? '',
      ) ??
          0,
      longitude: double.tryParse(
        json['longitude']?.toString() ?? '',
      ) ??
          0,
      images: (json['images'] as List<dynamic>? ?? [])
          .map(
            (image) => RemoteObservationImage.fromJson(
          image as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }
}


class RemoteObservationImage {
  final String uuid;
  final String url;
  final String? imageClass;
  final double? confidence;

  RemoteObservationImage({
    required this.uuid,
    required this.url,
    this.imageClass,
    this.confidence,
  });

  factory RemoteObservationImage.fromJson(
      Map<String, dynamic> json,
      ) {
    return RemoteObservationImage(
      uuid: json['uuid'] ?? '',
      url: json['url'] ?? '',
      imageClass: json['class'],
      confidence: json['confidence'] != null
          ? double.tryParse(
        json['confidence'].toString(),
      )
          : null,
    );
  }
}