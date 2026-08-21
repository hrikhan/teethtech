import '../../../../core/usecases/usecase.dart';
import '../../../../utils/typedefs.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase implements UseCase<AppUser?, NoParams> {
  final AuthRepository repository;

  const GetCurrentUserUseCase(this.repository);

  @override
  FutureEither<AppUser?> call(NoParams params) {
    return repository.checkAuthState();
  }
}
