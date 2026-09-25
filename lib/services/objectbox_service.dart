import 'package:objectbox/objectbox.dart';
import '../models/observation.dart';
import '../models/observation_image.dart';
import '../models/service.dart';
import '../models/user.dart';
import '../models/user_group.dart';
import '../models/user_service.dart';
import '../objectbox.g.dart';

class ObjectBoxService {
  late final Store store;

  late final Box<User> userBox;
  late final Box<Service> serviceBox;
  late final Box<UserService> userServiceBox;
  late final Box<UserGroup> userGroupBox;
  late final Box<Observation> observationBox;
  late final Box<ObservationImage> observationImageBox;

  ObjectBoxService._create(this.store) {
    userBox = Box<User>(store);
    serviceBox = Box<Service>(store);
    userServiceBox = Box<UserService>(store);
    userGroupBox = Box<UserGroup>(store);
    observationBox = Box<Observation>(store);
    observationImageBox = Box<ObservationImage>(store);
  }

  static Future<ObjectBoxService> create() async {
    final store = await openStore();
    return ObjectBoxService._create(store);
  }

  void close() {
    store.close();
  }
}