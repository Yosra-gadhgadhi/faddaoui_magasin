// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';

// // import 'main_nav_screen.dart';
// // import 'features/favorites/presentation/cubit/favorites_cubit.dart';
// // import 'features/grocery_list/cubit/grocery_list_cubit.dart';

// // void main() {
// //   runApp(
// //     MultiBlocProvider(
// //       providers: [
// //         BlocProvider(create: (_) => FavoritesCubit()),
// //         BlocProvider(create: (_) => GroceryListCubit()),
// //       ],
// //       child: const MyApp(),
// //     ),
// //   );
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return const MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       home: MainNavScreen(),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'main_nav_screen.dart';
// import 'features/favorites/presentation/cubit/favorites_cubit.dart';
// import 'features/grocery_list/cubit/grocery_list_cubit.dart';

// // ✅ AI
// import 'features/ai/data/mock_ai_service.dart';
// import 'features/ai/presentation/cubit/ai_cubit.dart';

// void main() {
//   runApp(
//     MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (_) => FavoritesCubit()),
//         BlocProvider(create: (_) => GroceryListCubit()),
//         BlocProvider(create: (_) => AiCubit(MockAiService())), // ✅ new
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: MainNavScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/routes.dart';
import 'core/theme/app_theme.dart';
import 'core/l10n/app_localizations.dart';
import 'core/l10n/tr3.dart';
import 'core/network/dio_client.dart';
import 'core/notifications/push_registration_service.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/request_reset.dart';
import 'features/auth/domain/usecases/reset_password.dart';
import 'features/auth/domain/usecases/sign_in.dart';
import 'features/auth/domain/usecases/sign_up.dart';
import 'features/auth/presentation/state/auth_cubit.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/grocery_list/cubit/grocery_list_cubit.dart';
import 'features/settings/presentation/cubit/app_settings_cubit.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';

// ✅ AI
import 'features/ai/data/mock_ai_service.dart';
import 'features/ai/presentation/cubit/ai_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final tokenStorage = TokenStorage();
  final dioClient = DioClient(tokenStorage);
  final authRemote = AuthRemoteDataSource(dioClient.dio);
  final AuthRepository authRepo =
      AuthRepositoryImpl(remote: authRemote, storage: tokenStorage);
  final pushRegistrationService = PushRegistrationService(dioClient.dio, tokenStorage);
  const initialRoute = AppRoutes.splash;

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TokenStorage>.value(value: tokenStorage),
        RepositoryProvider<AuthRepository>.value(value: authRepo),
        RepositoryProvider<PushRegistrationService>.value(value: pushRegistrationService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => CartCubit(dioClient.dio, tokenStorage)),
          BlocProvider(create: (_) => FavoritesCubit(dioClient.dio, tokenStorage)),
          BlocProvider(create: (_) => GroceryListCubit()),
          BlocProvider(create: (_) => AppSettingsCubit()),
          BlocProvider(create: (_) => AiCubit(MockAiService())),
          BlocProvider(
            create: (_) => NotificationsCubit(dioClient.dio, tokenStorage),
          ),
          BlocProvider(
            create: (ctx) {
              final repo = ctx.read<AuthRepository>();
              return AuthCubit(
                signInUC: SignIn(repo),
                signUpUC: SignUp(repo),
                requestResetUC: RequestReset(repo),
                resetPasswordUC: ResetPassword(repo),
                repo: repo,
              );
            },
          ),
        ],
        child: MyApp(initialRoute: initialRoute),
      ),
    ),
  );

  // Best effort bootstrap; if Firebase isn't configured yet, app still works.
  pushRegistrationService.initAndRegister();
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, settings) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: initialRoute,
          routes: AppRoutes.routes,
          locale: Locale(settings.languageCode),
          supportedLocales: const [
            Locale('fr'),
            Locale('en'),
            Locale('ar'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(animationsEnabled: settings.animationsEnabled),
          darkTheme: AppTheme.dark(
            animationsEnabled: settings.animationsEnabled,
          ),
          themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
          onUnknownRoute: (_) => MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(
                child: Text(
                  tr3(
                    context,
                    fr: "Route introuvable",
                    en: "Route not found",
                    ar: "المسار غير موجود",
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
