import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final bool isEmailVerified;
  final bool isAffiliate;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.isEmailVerified = false,
    this.isAffiliate = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'isEmailVerified': isEmailVerified,
        'isAffiliate': isAffiliate,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> map) => UserModel(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        isEmailVerified: map['isEmailVerified'] == true,
        isAffiliate: map['isAffiliate'] == true,
        createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );

  UserModel copyWith({
    String? name,
    String? email,
    bool? isEmailVerified,
    bool? isAffiliate,
  }) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        isEmailVerified: isEmailVerified ?? this.isEmailVerified,
        isAffiliate: isAffiliate ?? this.isAffiliate,
        createdAt: createdAt,
      );
}

enum AuthStatus { idle, loading, authenticated, unauthenticated }

/// In-memory store that survives hot restarts and can be persisted to a file
class _MemoryStore {
  static Map<String, dynamic> _data = {};

  static void set(String key, dynamic value) => _data[key] = value;
  static dynamic get(String key) => _data[key];
  static void remove(String key) => _data.remove(key);

  static Map<String, dynamic> users() =>
      (_data['users'] as Map<String, dynamic>?) ?? {};

  static void setUser(String email, Map<String, dynamic> userData) {
    final u = Map<String, dynamic>.from(users());
    u[email] = userData;
    _data['users'] = u;
  }
}

class AuthService extends ChangeNotifier {
  AuthStatus _status = AuthStatus.idle;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  // ─── Persistent file storage ───────────────────────────────────────────────

  static String? _storageDir;

  static Future<String> _getStoragePath() async {
    if (_storageDir != null) return '$_storageDir/achados_auth.json';
    // Use temp dir as fallback (available on Android without extra packages)
    try {
      final dir = Directory.systemTemp;
      _storageDir = dir.path;
      return '${dir.path}/achados_auth.json';
    } catch (_) {
      return '/tmp/achados_auth.json';
    }
  }

  Future<void> _loadFromDisk() async {
    try {
      final path = await _getStoragePath();
      final file = File(path);
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;
        _MemoryStore._data = Map<String, dynamic>.from(data);
      }
    } catch (_) {}
  }

  Future<void> _saveToDisk() async {
    try {
      final path = await _getStoragePath();
      final file = File(path);
      await file.writeAsString(jsonEncode(_MemoryStore._data));
    } catch (_) {}
  }

  // ─── Auth methods ─────────────────────────────────────────────────────────

  Future<void> init() async {
    _status = AuthStatus.loading;
    notifyListeners();

    await _loadFromDisk();

    // ── Seed test account se ainda não existir ──────────────────────────────
    final users = _MemoryStore.users();
    if (!users.containsKey('teste@achadosbr.com')) {
      _MemoryStore.setUser('teste@achadosbr.com', {
        'password': '123456',
        'profile': UserModel(
          id: 'test-001',
          name: 'Usuário Teste',
          email: 'teste@achadosbr.com',
          isEmailVerified: true,
          isAffiliate: true,
          createdAt: DateTime(2024, 1, 1),
        ).toJson(),
      });
    }
    // ────────────────────────────────────────────────────────────────────────

    final isLoggedIn = _MemoryStore.get('isLoggedIn') == true;
    final userJson = _MemoryStore.get('currentUser');

    if (isLoggedIn && userJson != null) {
      try {
        _currentUser = UserModel.fromJson(userJson as Map<String, dynamic>);
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

    final users = _MemoryStore.users();

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

    _currentUser = UserModel.fromJson(entry['profile'] as Map<String, dynamic>);
    _MemoryStore.set('isLoggedIn', true);
    _MemoryStore.set('currentUser', _currentUser!.toJson());
    await _saveToDisk();

    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  Future<bool> register(String name, String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1500));

    final users = _MemoryStore.users();
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
      isAffiliate: false,
      createdAt: DateTime.now(),
    );

    _MemoryStore.setUser(email, {
      'password': password,
      'profile': _currentUser!.toJson(),
    });
    _MemoryStore.set('isLoggedIn', true);
    _MemoryStore.set('currentUser', _currentUser!.toJson());
    await _saveToDisk();

    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  Future<bool> verifyEmail(String code) async {
    _status = AuthStatus.loading;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    if (code.length != 6) {
      _status = AuthStatus.authenticated;
      notifyListeners();
      return false;
    }

    final email = _currentUser?.email ?? '';
    final users = _MemoryStore.users();
    if (users.containsKey(email)) {
      final entry = Map<String, dynamic>.from(users[email] as Map<String, dynamic>);
      final profile = Map<String, dynamic>.from(entry['profile'] as Map<String, dynamic>);
      profile['isEmailVerified'] = true;
      entry['profile'] = profile;
      _MemoryStore.setUser(email, entry);
    }

    _currentUser = _currentUser?.copyWith(isEmailVerified: true);
    _MemoryStore.set('currentUser', _currentUser!.toJson());
    await _saveToDisk();

    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  Future<bool> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return _MemoryStore.users().containsKey(email);
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final users = _MemoryStore.users();
    if (users.containsKey(email)) {
      final entry = Map<String, dynamic>.from(users[email] as Map<String, dynamic>);
      entry['password'] = newPassword;
      _MemoryStore.setUser(email, entry);
      await _saveToDisk();
    }
    return true;
  }

  Future<void> activateAffiliate() async {
    final email = _currentUser?.email ?? '';
    final users = _MemoryStore.users();
    if (users.containsKey(email)) {
      final entry = Map<String, dynamic>.from(users[email] as Map<String, dynamic>);
      final profile = Map<String, dynamic>.from(entry['profile'] as Map<String, dynamic>);
      profile['isAffiliate'] = true;
      entry['profile'] = profile;
      _MemoryStore.setUser(email, entry);
    }
    _currentUser = _currentUser?.copyWith(isAffiliate: true);
    _MemoryStore.set('currentUser', _currentUser!.toJson());
    await _saveToDisk();
    notifyListeners();
  }

  Future<void> logout() async {
    _MemoryStore.set('isLoggedIn', false);
    _MemoryStore.remove('currentUser');
    await _saveToDisk();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
