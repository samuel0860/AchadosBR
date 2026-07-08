import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'theme_service.dart' show getStorageFile;

export '../models/user_model.dart';

enum AuthStatus { idle, loading, authenticated, unauthenticated }

class AuthService extends ChangeNotifier {
  AuthStatus _status = AuthStatus.idle;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _status == AuthStatus.authenticated;
  bool get isAffiliate => _currentUser?.isAffiliateUser ?? false;

  // ─── File-based persistence ────────────────────────────────────────────────

  Future<File> _getFile() => getStorageFile('achados_auth.json');

  Future<Map<String, dynamic>> _load() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        return Map<String, dynamic>.from(
            jsonDecode(content) as Map<String, dynamic>);
      }
    } catch (_) {}
    return {};
  }

  Future<void> _save(Map<String, dynamic> data) async {
    try {
      final file = await _getFile();
      await file.writeAsString(jsonEncode(data));
    } catch (_) {}
  }

  // ─── Auth methods ─────────────────────────────────────────────────────────

  Future<void> init() async {
    _status = AuthStatus.loading;
    notifyListeners();

    var data = await _load();

    // ── Seed test accounts ──────────────────────────────────────────────────
    final users = Map<String, dynamic>.from(
        (data['users'] as Map<String, dynamic>?) ?? {});

    users['teste@AchouAchado.com'] = {
      'password': '123456',
      'profile': UserModel(
        id: 'test-cliente-001',
        name: 'Usuário Teste',
        email: 'teste@AchouAchado.com',
        isEmailVerified: true,
        isAffiliate: false,
        userType: UserType.cliente,
        createdAt: DateTime(2024, 1, 1),
        bio: 'Amo encontrar as melhores ofertas!',
        avatarColor: '#10B981',
      ).toJson(),
    };

    users['afiliado@AchouAchado.com'] = {
      'password': '123456',
      'profile': UserModel(
        id: 'test-afiliado-001',
        name: 'Afiliado Teste',
        email: 'afiliado@AchouAchado.com',
        isEmailVerified: true,
        isAffiliate: true,
        userType: UserType.afiliado,
        createdAt: DateTime(2024, 1, 1),
        bio: 'Especialista em encontrar os melhores preços do Brasil.',
        avatarColor: '#D4AF37',
      ).toJson(),
    };

    data['users'] = users;
    await _save(data);
    // ─────────────────────────────────────────────────────────────────────────

    final isLoggedIn = data['isLoggedIn'] == true;
    final userJson = data['currentUser'];

    if (isLoggedIn && userJson != null) {
      try {
        _currentUser =
            UserModel.fromJson(userJson as Map<String, dynamic>);
        _status = AuthStatus.authenticated;
      } catch (_) {
        _status = AuthStatus.unauthenticated;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));

    final data = await _load();
    final users = Map<String, dynamic>.from(
        (data['users'] as Map<String, dynamic>?) ?? {});

    if (!users.containsKey(email)) {
      _errorMessage = 'E-mail não cadastrado. Faça o cadastro primeiro.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }

    final entry = users[email] as Map<String, dynamic>;
    if (entry['password'] != password) {
      _errorMessage = 'Senha incorreta. Tente novamente.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }

    _currentUser =
        UserModel.fromJson(entry['profile'] as Map<String, dynamic>);
    data['isLoggedIn'] = true;
    data['currentUser'] = _currentUser!.toJson();
    await _save(data);

    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  Future<bool> register(String name, String email, String password,
      {UserType userType = UserType.cliente}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1500));

    final data = await _load();
    final users = Map<String, dynamic>.from(
        (data['users'] as Map<String, dynamic>?) ?? {});

    if (users.containsKey(email)) {
      _errorMessage = 'Este e-mail já está cadastrado.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }

    final userId = DateTime.now().millisecondsSinceEpoch.toString();
    _currentUser = UserModel(
      id: userId,
      name: name,
      email: email,
      isEmailVerified: false,
      isAffiliate: userType == UserType.afiliado,
      userType: userType,
      createdAt: DateTime.now(),
      avatarColor: '#7C3AED',
    );

    users[email] = {
      'password': password,
      'profile': _currentUser!.toJson(),
    };
    data['users'] = users;
    data['isLoggedIn'] = true;
    data['currentUser'] = _currentUser!.toJson();
    await _save(data);

    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  Future<bool> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final data = await _load();
    final users = (data['users'] as Map<String, dynamic>?) ?? {};
    return users.containsKey(email);
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final data = await _load();
    final users = Map<String, dynamic>.from(
        (data['users'] as Map<String, dynamic>?) ?? {});
    if (users.containsKey(email)) {
      final entry =
          Map<String, dynamic>.from(users[email] as Map<String, dynamic>);
      entry['password'] = newPassword;
      users[email] = entry;
      data['users'] = users;
      await _save(data);
    }
    return true;
  }

  Future<void> updateProfile({
    String? name,
    String? bio,
    String? avatarColor,
  }) async {
    final email = _currentUser?.email ?? '';
    final data = await _load();
    final users = Map<String, dynamic>.from(
        (data['users'] as Map<String, dynamic>?) ?? {});

    if (users.containsKey(email)) {
      final entry =
          Map<String, dynamic>.from(users[email] as Map<String, dynamic>);
      final profile =
          Map<String, dynamic>.from(entry['profile'] as Map<String, dynamic>);
      if (name != null) profile['name'] = name;
      if (bio != null) profile['bio'] = bio;
      if (avatarColor != null) profile['avatarColor'] = avatarColor;
      entry['profile'] = profile;
      users[email] = entry;
      data['users'] = users;
    }

    _currentUser = _currentUser?.copyWith(
      name: name,
      bio: bio,
      avatarColor: avatarColor,
    );
    data['currentUser'] = _currentUser!.toJson();
    await _save(data);
    notifyListeners();
  }

  Future<void> logout() async {
    final data = await _load();
    data['isLoggedIn'] = false;
    data.remove('currentUser');
    await _save(data);
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
