import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppUser {
  final String id;
  final String email;
  final String username;
  final String role;
  final String phone;
  final String country;
  final String state;
  final String city;
  final String address;

  const AppUser({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    this.phone = '',
    this.country = '',
    this.state = '',
    this.city = '',
    this.address = '',
  });

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
    id: map['id'] as String,
    email: map['email'] as String? ?? '',
    username: map['username'] as String,
    role: (map['role'] as String).toLowerCase(),
    phone: map['phone'] as String? ?? '',
    country: map['country'] as String? ?? '',
    state: map['state'] as String? ?? '',
    city: map['city'] as String? ?? '',
    address: map['address'] as String? ?? '',
  );
}

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  AppUser? _currentUser;
  bool _isCheckingSession = true;

  AuthProvider() {
    _restoreSession();
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isCheckingSession => _isCheckingSession;

  Future<void> _restoreSession() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) await _loadProfile(user.id);
    } finally {
      _isCheckingSession = false;
      notifyListeners();
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (response.user == null) return 'Could not sign in.';
      final profileLoaded = await _loadProfile(response.user!.id);
      return profileLoaded
          ? null
          : 'Your account has no profile yet. Run the Supabase profile repair SQL, then sign in again.';
    } on AuthException catch (error) {
      return _friendlyAuthError(error.message);
    } on PostgrestException catch (error) {
      return 'Signed in, but your profile could not be loaded: ${error.message}';
    }
  }

  Future<String?> resendConfirmation(String email) async {
    try {
      await _supabase.auth.resend(type: OtpType.signup, email: email.trim());
      return null;
    } on AuthException catch (error) {
      return _friendlyAuthError(error.message);
    }
  }

  Future<String?> register({
    required String email,
    required String username,
    required String password,
    required String role,
    required String phone,
    required String country,
    required String state,
    required String city,
    required String address,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'username': username.trim().toLowerCase(),
          'role': role.toLowerCase(),
          'phone': phone,
          'country': country,
          'state': state,
          'city': city,
          'address': address,
        },
      );
      if (response.user == null) {
        return 'Supabase did not create the account.';
      }
      if (response.user!.identities?.isEmpty ?? false) {
        return 'This username is already registered.';
      }
      // Signup should return to the Login screen, even when email confirmation
      // is disabled and Supabase creates a session immediately.
      if (response.session != null) {
        await _supabase.auth.signOut();
      }
      return null;
    } on AuthException catch (error) {
      return _friendlyAuthError(error.message);
    }
  }

  String _friendlyAuthError(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('rate limit') ||
        normalized.contains('too many requests')) {
      return 'Supabase email limit reached. Disable email confirmation in '
          'Supabase Auth settings for this username demo, or wait for the '
          'limit to reset.';
    }
    if (normalized.contains('invalid email')) {
      return 'Enter a valid email address.';
    }
    if (normalized.contains('email not confirmed')) {
      return 'Please confirm your email address before signing in. Check your inbox.';
    }
    if (normalized.contains('invalid login credentials')) {
      return 'The email or password is incorrect.';
    }
    return message;
  }

  Future<bool> _loadProfile(String userId) async {
    final profile = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (profile == null) {
      _currentUser = null;
      notifyListeners();
      return false;
    }
    _currentUser = AppUser.fromMap(profile);
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
