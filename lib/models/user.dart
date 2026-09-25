import 'package:objectbox/objectbox.dart';

@Entity()
class User {
  @Id()
  int id = 0;

  String uuid;
  String name;
  String username;
  String email;

  /// Caminho local para a fotografia de perfil.
  String avatarLocalPath;
  String avatarUrl;

  /// Número de observações enviadas pelo utilizador.
  int nrObs;

  User({
    this.uuid = '',
    this.name = '',
    this.username = '',
    this.email = '',
    this.avatarLocalPath = '',
    this.avatarUrl = '',
    this.nrObs = 0,
  });
}