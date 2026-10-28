import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(name: '', email: '');
  bool _isLoading = true;
  bool _isDarkMode = false;
  int _visitCount = 0;
  List<String> _favorites = [];

  User get user => _user;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  int get visitCount => _visitCount;
  List<String> get favorites => List.unmodifiable(_favorites);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final visitCount = (prefs.getInt('visit_count') ?? 0) + 1;
    await prefs.setInt('visit_count', visitCount);

    _user = User(
      name: prefs.getString('user_name') ?? '',
      email: prefs.getString('user_email') ?? '',
      isLoggedIn: prefs.getBool('is_logged_in') ?? false,
    );
    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    _visitCount = visitCount;
    _favorites = prefs.getStringList('favorites') ?? [];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUser(User newUser) async {
    final prefs = await SharedPreferences.getInstance();
    _isLoading = true;
    notifyListeners();
    try {
      await prefs.setString('user_name', newUser.name);
      await prefs.setString('user_email', newUser.email);
      await prefs.setBool('is_logged_in', newUser.isLoggedIn);
      final usedEmails = prefs.getStringList('used_emails') ?? [];
      if (!usedEmails.contains(newUser.email.toLowerCase())) {
        await prefs.setStringList('used_emails', [
          ...usedEmails,
          newUser.email.toLowerCase(),
        ]);
      }
      _user = newUser;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.setBool('is_logged_in', false);
    _user = _user.copyWith(name: '', isLoggedIn: false);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDarkMode);
    _isDarkMode = isDarkMode;
    notifyListeners();
  }

  Future<bool> isEmailAlreadyUsed(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email')?.trim().toLowerCase();
    final currentEmail = _user.email.trim().toLowerCase();
    final normalizedEmail = email.trim().toLowerCase();
    final usedEmails = prefs.getStringList('used_emails') ?? [];
    final isUsedByAnotherProfile = usedEmails
        .map((usedEmail) => usedEmail.trim().toLowerCase())
        .contains(normalizedEmail);
    return (savedEmail == normalizedEmail && savedEmail != currentEmail) ||
        (isUsedByAnotherProfile && normalizedEmail != currentEmail);
  }

  Future<void> addFavorite(String favorite) async {
    final value = favorite.trim();
    if (value.isEmpty || _favorites.contains(value)) return;

    final favorites = [..._favorites, value];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', favorites);
    _favorites = favorites;
    notifyListeners();
  }

  Future<void> removeFavorite(String favorite) async {
    final favorites = _favorites.where((item) => item != favorite).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', favorites);
    _favorites = favorites;
    notifyListeners();
  }
}
