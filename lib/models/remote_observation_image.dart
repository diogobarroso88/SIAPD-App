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