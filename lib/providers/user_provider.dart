import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService;

  List<AppUser> _users = [];
  List<AppUser> get users => _users;

  UserProvider(this._userService) {
    _userService.streamAllUsers().listen((list) {
      _users = list;
      notifyListeners();
    });
  }

  Future<void> updateUser(AppUser user) async {
    await _userService.updateUser(user);
  }
}
