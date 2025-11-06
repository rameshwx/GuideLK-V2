import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/admin_user.dart';
import 'sample_data.dart';

final usersProvider = StateNotifierProvider<UsersController, List<AdminUser>>(
  (ref) => UsersController(buildSampleUsers()),
);

class UsersController extends StateNotifier<List<AdminUser>> {
  UsersController(List<AdminUser> initialUsers) : super(initialUsers);

  void toggleActive(AdminUser user) {
    state = [
      for (final u in state)
        if (u.id == user.id)
          u.copyWith(active: !u.active)
        else
          u,
    ];
  }

  void updateUser(AdminUser updated) {
    state = [
      for (final user in state)
        if (user.id == updated.id) updated else user,
    ];
  }
}
