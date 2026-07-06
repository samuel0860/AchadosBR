import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

export '../models/user_model.dart';

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
  bool get isAffiliate => _currentUser?.isAffiliateUser ?? false;

  // ─── Persistent file storage ───────────────────────────────────────────────

  static String? _storageDir;

  static Future<String> _getStoragePath() async {
    if (_storageDir != null) return '$_storageDir/achados_auth.json';
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

    // ── Seed test accounts (sempre atualiza para garantir tipos corretos) ────
    _MemoryStore.setUser('teste@achadosbr.com', {
      'password': '123456',
      'profile': UserModel(
        id: 'test-cliente-001',
        name: 'Usuário Teste',
        email: 'teste@achadosbr.com',
        isEmailVerified: true,
        isAffiliate: false,
        userType: UserType.cliente,
        createdAt: DateTime(2024, 1, 1),
        bio: 'Amo encontrar as melhores ofertas!',
        avatarColor: '#10B981',
      ).toJson(),
    });

    _MemoryStore.setUser('afiliado@achadosbr.com', {
      'password': '123456',
      'profile': UserModel(
        id: 'test-afiliado-001',
        name: 'Afiliado Teste',
        email: 'afiliado@achadosbr.com',
        isEmailVerified: true,
        isAffiliate: true,
        userType: UserType.afiliado,
        createdAt: DateTime(2024, 1, 1),
        bio: 'Especialista em encontrar os melhores preços do Brasil.',
        avatarColor: '#D4AF37',
      ).toJson(),
    });
    // ─────────────────────────────────────────────────────────────────────────

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

  Future<bool> register(String name, String email, String password,
      {UserType userType = UserType.cliente}) async {
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
      isAffiliate: userType == UserType.afiliado,
      userType: userType,
      createdAt: DateTime.now(),
      avatarColor: '#7C3AED',
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

  Future<void> updateProfile({
    String? name,
    String? bio,
    String? avatarColor,
  }) async {
    final email = _currentUser?.email ?? '';
    final users = _MemoryStore.users();
    if (users.containsKey(email)) {
      final entry = Map<String, dynamic>.from(users[email] as Map<String, dynamic>);
      final profile = Map<String, dynamic>.from(entry['profile'] as Map<String, dynamic>);
      if (name != null) profile['name'] = name;
      if (bio != null) profile['bio'] = bio;
      if (avatarColor != null) profile['avatarColor'] = avatarColor;
      entry['profile'] = profile;
      _MemoryStore.setUser(email, entry);
    }
    _currentUser = _currentUser?.copyWith(
      name: name,
      bio: bio,
      avatarColor: avatarColor,
    );
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
