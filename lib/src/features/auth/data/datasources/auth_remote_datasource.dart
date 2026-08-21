import 'package:dio/dio.dart';
import '../../../../config/app_config.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  });
  Future<void> forgotPassword({required String email});
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? AppConfig.dio;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post<Map<String, dynamic>>('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = response.data!;
    final userData = (data['user'] ?? data) as Map<String, dynamic>;
    return UserModel.fromJson(userData);
  }

  @override
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await dio.post<Map<String, dynamic>>('/auth/signup', data: {
      'name': name,
      'email': email,
      'password': password,
    });
    final data = response.data!;
    final userData = (data['user'] ?? data) as Map<String, dynamic>;
    return UserModel.fromJson(userData);
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await dio.post<void>('/auth/forgot-password', data: {'email': email});
  }

  @override
  Future<void> logout() async {
    await dio.post<void>('/auth/logout');
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final response = await dio.get<Map<String, dynamic>>('/auth/me');
    if (response.data == null) return null;
    final userData = (response.data!['user'] ?? response.data!) as Map<String, dynamic>;
    return UserModel.fromJson(userData);
  }
}
