import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';

import 'providers/index.dart';
import 'repositories/index.dart';
import 'utils/index.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  const flavorStr = String.fromEnvironment('FLAVOR');
  Flavor flavor;
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

  runApp(
    MultiProvider(
      providers: [
        Provider<Flavor>.value(value: flavor),
        Provider<FirebaseAuthenticationRepository>(
          create: (_) => FirebaseAuthenticationRepository(
            firebaseAuth: firebaseAuth,
          ),
        ),
        Provider<FirebaseUserRepository>(
          create: (_) => FirebaseUserRepository(
            firebaseAuth: firebaseAuth,
            firebaseFirestore: firebaseFirestore,
          ),
        ),
        ChangeNotifierProvider<CurrentUserProvider>(
          create: (_) => CurrentUserProvider(
            authRepository: FirebaseAuthenticationRepository(
              firebaseAuth: firebaseAuth,
            ),
          ),
        ),
        ChangeNotifierProvider<UsersProvider>(
          create: (_) => UsersProvider(
            authRepository: FirebaseAuthenticationRepository(
              firebaseAuth: firebaseAuth,
            ),
            userRepository: FirebaseUserRepository(
              firebaseAuth: firebaseAuth,
              firebaseFirestore: firebaseFirestore,
            ),
          ),
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
