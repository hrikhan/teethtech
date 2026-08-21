import '../../imports/imports.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/providers/auth_bloc.dart';
import '../../features/auth/presentation/providers/session_bloc.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/catalog/presentation/bloc/wishlist_bloc.dart';
import '../../features/categories/presentation/bloc/categories_bloc.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/orders/presentation/bloc/orders_bloc.dart';
import '../../features/quotations/presentation/bloc/quotations_bloc.dart';

/// Central wrapper to initialize all global Blocs and Cubits for TeethTech.
class StateWrapper extends StatelessWidget {
  final Widget child;

  const StateWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepositoryImpl();

    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(),
        ),
        BlocProvider<SessionBloc>(
          create: (_) => SessionBloc(repository: authRepository),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(repository: authRepository),
        ),
        BlocProvider<HomeBloc>(
          create: (_) => HomeBloc(),
        ),
        BlocProvider<CategoriesBloc>(
          create: (_) => CategoriesBloc(),
        ),
        BlocProvider<CartBloc>(
          create: (_) => CartBloc(),
        ),
        BlocProvider<OrdersBloc>(
          create: (_) => OrdersBloc(),
        ),
        BlocProvider<WishlistBloc>(
          create: (_) => WishlistBloc(),
        ),
        BlocProvider<QuotationsBloc>(
          create: (_) => QuotationsBloc(),
        ),
      ],
      child: child,
    );
  }
}
