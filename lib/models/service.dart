import 'package:objectbox/objectbox.dart';

@Entity()
class Service {
  @Id()
  int id = 0;

  String uuid;
  String name;
  String slug;
  bool open;

  Service({
    this.uuid = '',
    this.name = '',
    this.slug = '',
    this.open = false,
  });
}