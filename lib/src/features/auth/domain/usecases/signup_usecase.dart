import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../utils/typedefs.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase implements UseCase<AppUser, SignUpParams> {
  final AuthRepository repository;

  const SignUpUseCase(this.repository);

  @override
  FutureEither<AppUser> call(SignUpParams params) {
    return repository.signUp(
      name: params.name,
      email: params.email,
      password: params.password,
    );
  }
}

class SignUpParams extends Equatable {
  final String name;
  final String email;
  final String password;

  const SignUpParams({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}
