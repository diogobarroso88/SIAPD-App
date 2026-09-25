import 'package:objectbox/objectbox.dart';

@Entity()
class ObservationImage {
  @Id()
  int id = 0;

  /// ID local da observação.
  int observationId;

  /// Caminho local da fotografia.
  String localPath;

  /// UUID da imagem no servidor, caso já tenha sido enviada.
  String remoteUuid;

  /// Indica se esta imagem já foi enviada.
  bool uploaded;

  ObservationImage({
    this.observationId = 0,
    this.localPath = '',
    this.remoteUuid = '',
    this.uploaded = false,
  });
}