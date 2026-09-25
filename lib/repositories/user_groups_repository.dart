import '../models/user_group.dart';
import '../services/api_service.dart';
import '../services/objectbox_service.dart';
import '../objectbox.g.dart';

class UserGroupsRepository {
  final ApiService apiService;
  final ObjectBoxService objectBox;

  UserGroupsRepository({
    required this.apiService,
    required this.objectBox,
  });

  Future<void> syncUserGroups(String userUuid) async {
    final response = await apiService.dio.get('/usergroups');

    final data = response.data as Map<String, dynamic>;
    final groupsData = data['groups'] as List<dynamic>? ?? [];

    for (final item in groupsData) {
      final groupData = item as Map<String, dynamic>;

      final groupUuid = groupData['uuid'] as String? ?? '';
      final groupName = groupData['name'] as String? ?? '';

      if (groupUuid.isEmpty) {
        continue;
      }

      final group = UserGroup(
        userUuid: userUuid,
        uuid: groupUuid,
        name: groupName,
      );

      final existingGroup = objectBox.userGroupBox
          .query(
        UserGroup_.userUuid.equals(userUuid) &
        UserGroup_.uuid.equals(groupUuid),
      )
          .build()
          .findFirst();

      if (existingGroup != null) {
        group.id = existingGroup.id;
      }

      objectBox.userGroupBox.put(group);
    }
  }
}