import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/features/splash/presentation/splash_page.dart';
import 'package:user/features/home/presentation/pages/home_page.dart';
import 'core/di/injection.dart' as di;
import 'core/utils/translations.dart';
import 'features/language/bloc/language_bloc.dart';
import 'features/language/bloc/language_state.dart';
import 'domain/repositories/auth_repository.dart';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart' as di;
import 'core/utils/navigation.dart';      // global navigatorKey
import 'core/utils/translations.dart';
import 'features/language/bloc/language_bloc.dart';
import 'features/language/bloc/language_state.dart';
import 'features/splash/presentation/splash_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/auth/presentation/pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  final authRepo = di.sl<AuthRepository>();
  final result = await authRepo.getSavedUser();

  Widget startScreen = const SplashPage();

  result.fold(
        (failure) => startScreen = const SplashPage(),
        (user) {
      if (user.accessToken.isNotEmpty) {
        startScreen = const HomePage();
      } else {
        startScreen = const SplashPage();
      }
    },
  );

  runApp(MyApp(startScreen: startScreen));
}

class MyApp extends StatelessWidget {
  final Widget startScreen;

  const MyApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<LanguageBloc>(),
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, state) {
          return MaterialApp(
            title: AppTranslations.get('app_name'),
            theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: 'Poppins',
            ),
            navigatorKey: navigatorKey,          // ← critical
            home: startScreen,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
