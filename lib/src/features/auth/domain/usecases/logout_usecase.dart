import '../../../../core/usecases/usecase.dart';
import '../../../../utils/typedefs.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  const LogoutUseCase(this.repository);

  @override
  FutureEither<void> call(NoParams params) {
    return repository.logout();
  }
}
