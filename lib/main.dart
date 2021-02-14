import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'blocs/global_blocs/authentication_bloc/index.dart';
import 'blocs/global_blocs/current_user_bloc/index.dart';
import 'util/index.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  const flavor = String.fromEnvironment('FLAVOR');
  if (flavor == 'development') {
    debugPrint('FLAVOR: development');
  } else if (flavor == 'staging') {
    debugPrint('FLAVOR: staging');
  } else if (flavor == 'production') {
    debugPrint('FLAVOR: production');
  } else {
    throw Exception('--dart-define=FLAVOR=xxx should be specified.');
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (context) => AuthenticationBloc()..add(AppStarted()),
        ),
        BlocProvider<CurrentUserBloc>(
          create: (context) => CurrentUserBloc(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: MaterialApp(
        title: '狩友Rise',
        theme: defaultTheme,
        onGenerateRoute: Routes.generateRoute,
        onUnknownRoute: Routes.errorRoute,
      ),
    );
  }
}
