import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'localizations/ja.dart';
import 'stores/authentication_store.dart';
import 'stores/users_store.dart';
import 'util/routes.dart';
import 'util/style.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  const flavor = String.fromEnvironment('FLAVOR');
  if (flavor == 'development') {
    debugPrint('FLAVOR development');
  } else if (flavor == 'staging') {
    debugPrint('FLAVOR development');
  } else if (flavor == 'production') {
    debugPrint('FLAVOR development');
  } else {
    throw Exception('--dart-define=FLAVOR=xxx should be specified.');
  }

  // サインインしていない場合は匿名でサインインする
  final firebaseAuth = FirebaseAuth.instance;
  final currentUser = firebaseAuth.currentUser;
  if (currentUser == null) {
    await firebaseAuth.signInAnonymously();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthenticationStore()..init(),
        ),
        ChangeNotifierProvider(
          create: (context) => UsersStore(),
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
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          JapaneseCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ja', 'JP')],
        locale: const Locale('ja', 'JP'),
      ),
    );
  }
}
