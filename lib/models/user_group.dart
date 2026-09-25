import 'package:objectbox/objectbox.dart';

@Entity()
class UserGroup {
  @Id()
  int id = 0;

  String userUuid;
  String uuid;
  String name;

  UserGroup({
    this.userUuid = '',
    this.uuid = '',
    this.name = '',
  });
}