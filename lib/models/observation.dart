import 'package:objectbox/objectbox.dart';

import 'package:objectbox/objectbox.dart';

@Entity()
class Observation {
  @Id()
  int id = 0;


  String remoteUuid;
  String userUuid;
  String serviceUuid;
  String serviceSlug;
  String userGroupUuid;


  String title;
  String titleUuid;
  String description;

  double latitude;
  double longitude;

  String geocode;

  bool isPublic;
  
  String syncStatus;

  DateTime createdAt;

  Observation({
    this.remoteUuid = '',
    this.userUuid = '',
    this.serviceUuid = '',
    this.serviceSlug = '',
    this.userGroupUuid = '',
    this.title = '',
    this.titleUuid = '',
    this.description = '',
    this.latitude = 0,
    this.longitude = 0,
    this.geocode = '',
    this.isPublic = false,
    this.syncStatus = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}