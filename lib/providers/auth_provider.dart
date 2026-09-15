import 'package:flutter/foundation.dart';

class AppUser {
  final String username;
  final String password;
  final String role;
  final String phone;
  final String country;
  final String state;
  final String city;
  final String address;

  const AppUser({
    required this.username,
    required this.password,
    required this.role,
    this.phone = '',
    this.country = '',
    this.state = '',
    this.city = '',
    this.address = '',
  });
}

class AuthProvider extends ChangeNotifier {
  final Map<String, AppUser> _users = {
    'sachu': const AppUser(
      username: 'sachu',
      password: 'sa123',
      role: 'Seller',
    ),
    'sachubs': const AppUser(
      username: 'sachubs',
      password: 'sa123',
      role: 'Buyer',
    ),
  };

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  bool login(String username, String password) {
    final normalizedUsername = username.trim().toLowerCase();
    final user = _users[normalizedUsername];
    if (user == null || user.password != password) return false;

    _currentUser = user;
    notifyListeners();
    return true;
  }

  bool register(AppUser user) {
    final normalizedUsername = user.username.trim().toLowerCase();
    if (_users.containsKey(normalizedUsername)) return false;

    _users[normalizedUsername] = AppUser(
      username: normalizedUsername,
      password: user.password,
      role: user.role,
      phone: user.phone,
      country: user.country,
      state: user.state,
      city: user.city,
      address: user.address,
    );
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
