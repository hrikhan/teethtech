import 'dart:async';
import '../../../../imports/core_imports.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_mock_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final StreamController<AppUser?> _authStateController =
      StreamController<AppUser?>.broadcast();

  AuthRepositoryImpl({
    AuthRemoteDataSource? remoteDataSource,
    AuthLocalDataSource? localDataSource,
  })  : _remoteDataSource = remoteDataSource ??
            (AppConfig.useMockApi
                ? AuthMockDataSourceImpl()
                : AuthRemoteDataSourceImpl()),
        _localDataSource = localDataSource ?? AuthLocalDataSourceImpl();

  @override
  Stream<AppUser?> get onAuthStateChanged => _authStateController.stream;

  @override
  FutureEither<AppUser> login({
    required String email,
    required String password,
  }) {
    return runTask(() async {
      final user = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      await _localDataSource.saveUser(user);
      _authStateController.add(user);
      return user;
    }, requiresNetwork: !AppConfig.useMockApi);
  }

  @override
  FutureEither<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return runTask(() async {
      final user = await _remoteDataSource.signUp(
        name: name,
        email: email,
        password: password,
      );
      await _localDataSource.saveUser(user);
      _authStateController.add(user);
      return user;
    }, requiresNetwork: !AppConfig.useMockApi);
  }

  @override
  FutureEither<void> forgotPassword({required String email}) {
    return runTask(() async {
      await _remoteDataSource.forgotPassword(email: email);
    }, requiresNetwork: !AppConfig.useMockApi);
  }

  @override
  FutureEither<void> logout() {
    return runTask(() async {
      await _remoteDataSource.logout();
      await _localDataSource.clearUser();
      _authStateController.add(null);
    }, requiresNetwork: !AppConfig.useMockApi);
  }

  @override
  FutureEither<AppUser?> checkAuthState() {
    return runTask(() async {
      // First check locally cached session
      final localUser = await _localDataSource.getUser();
      if (localUser != null) {
        _authStateController.add(localUser);
        return localUser;
      }

      // Check remote session if connected
      final remoteUser = await _remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        await _localDataSource.saveUser(remoteUser);
        _authStateController.add(remoteUser);
        return remoteUser;
      }

      _authStateController.add(null);
      return null;
    });
  }

  void dispose() {
    _authStateController.close();
  }
}
