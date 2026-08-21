import 'package:equatable/equatable.dart';
import '../../utils/typedefs.dart';

/// Base contract for all Clean Architecture Use Cases.
///
/// Every use case takes a parameter of type [Params] and returns a [FutureEither<T>].
abstract class UseCase<T, Params> {
  FutureEither<T> call(Params params);
}

/// Use this when a Use Case does not require any parameters.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
