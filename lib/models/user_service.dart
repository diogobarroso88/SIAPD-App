import 'package:objectbox/objectbox.dart';

@Entity()
class UserService {
  @Id()
  int id = 0;

  String userUuid;
  String serviceUuid;
  bool subscribed;

  UserService({
    this.userUuid = '',
    this.serviceUuid = '',
    this.subscribed = false,
  });
}