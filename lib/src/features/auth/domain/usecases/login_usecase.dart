import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../utils/typedefs.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<AppUser, LoginParams> {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  @override
  FutureEither<AppUser> call(LoginParams params) {
    return repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}
