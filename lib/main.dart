import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'localizations/index.dart';
import 'notifiers/index.dart';
import 'repositories/index.dart';
import 'util/index.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Flavor flavor;
  const flavorStr = String.fromEnvironment('FLAVOR');
  if (flavorStr == 'development') {
    flavor = Flavor.development;
  } else if (flavorStr == 'staging') {
    flavor = Flavor.staging;
  } else if (flavorStr == 'production') {
    flavor = Flavor.production;
  } else {
    throw Exception('--dart-define=FLAVOR=xxx should be specified.');
  }

  final firebaseAuth = FirebaseAuth.instance;
  final firebaseFirestore = FirebaseFirestore.instance;

  final authRepository = FirebaseAuthenticationRepository(
    firebaseAuth: firebaseAuth,
  );
  final publicRepository = FirebasePublicRepository(
    firebaseFirestore: firebaseFirestore,
  );
  final userRepository = FirebaseUserRepository(
    firebaseAuth: firebaseAuth,
    firebaseFirestore: firebaseFirestore,
  );
  final postRepository = FirebasePostRepository(
    firebaseAuth: firebaseAuth,
    firebaseFirestore: firebaseFirestore,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<Flavor>.value(value: flavor),
        Provider<FirebaseAuthenticationRepository>.value(value: authRepository),
        Provider<FirebasePublicRepository>.value(value: publicRepository),
        Provider<FirebaseUserRepository>.value(value: userRepository),
        Provider<FirebasePostRepository>.value(value: postRepository),
      ],
      child: ChangeNotifierProvider(
        create: (context) => AuthenticationNotifier(
          authRepository: context.read<FirebaseAuthenticationRepository>(),
          userRepository: context.read<FirebaseUserRepository>(),
        ),
        child: MyApp(),
      ),
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
