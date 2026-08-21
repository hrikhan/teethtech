import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../utils/typedefs.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase implements UseCase<void, ForgotPasswordParams> {
  final AuthRepository repository;

  const ForgotPasswordUseCase(this.repository);

  @override
  FutureEither<void> call(ForgotPasswordParams params) {
    return repository.forgotPassword(email: params.email);
  }
}

class ForgotPasswordParams extends Equatable {
  final String email;

  const ForgotPasswordParams({required this.email});

  @override
  List<Object?> get props => [email];
}
