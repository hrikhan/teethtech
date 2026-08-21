import 'dart:convert';
import '../../../../services/secure_storage_service.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();
  Future<void> saveToken(String token);
  Future<String?> getToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _userKey = 'cached_user_profile';
  static const String _tokenKey = 'auth_jwt_token';

  final SecureStorageService _storage;

  AuthLocalDataSourceImpl({SecureStorageService? storage})
      : _storage = storage ?? SecureStorageService.instance;

  @override
  Future<void> saveUser(UserModel user) async {
    final rawJson = jsonEncode(user.toJson());
    await _storage.write(_userKey, rawJson);
  }

  @override
  Future<UserModel?> getUser() async {
    final result = await _storage.read(_userKey);
    return result.fold(
      (failure) => null,
      (rawJson) {
        if (rawJson == null || rawJson.isEmpty) return null;
        try {
          final map = jsonDecode(rawJson) as Map<String, dynamic>;
          return UserModel.fromJson(map);
        } catch (_) {
          return null;
        }
      },
    );
  }

  @override
  Future<void> clearUser() async {
    await _storage.delete(_userKey);
    await _storage.delete(_tokenKey);
  }

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(_tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    final result = await _storage.read(_tokenKey);
    return result.fold((failure) => null, (token) => token);
  }
}
