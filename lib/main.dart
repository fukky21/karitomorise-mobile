import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'blocs/authentication_bloc/index.dart';
import 'localizations/index.dart';
import 'providers/index.dart';
import 'repositories/index.dart';
import 'utils/index.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final firebaseAuth = FirebaseAuth.instance;
  final firebaseFirestore = FirebaseFirestore.instance;

  runApp(
    MultiProvider(
      providers: [
        Provider<Flavor>(
          create: (_) {
            const flavorStr = String.fromEnvironment('FLAVOR');
            if (flavorStr == 'development') {
              return Flavor.development;
            }
            if (flavorStr == 'staging') {
              return Flavor.staging;
            }
            if (flavorStr == 'production') {
              return Flavor.production;
            }
            throw Exception('--dart-define=FLAVOR=xxx should be specified.');
          },
        ),
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
        Provider<FirebaseEventRepository>(
          create: (_) => FirebaseEventRepository(
            firebaseAuth: firebaseAuth,
            firebaseFirestore: firebaseFirestore,
          ),
        ),
        Provider<FirebaseEventCommentRepository>(
          create: (_) => FirebaseEventCommentRepository(
            firebaseAuth: firebaseAuth,
            firebaseFirestore: firebaseFirestore,
          ),
        ),
        Provider<FirebasePublicRepository>(
          create: (_) => FirebasePublicRepository(
            firebaseFirestore: firebaseFirestore,
          ),
        ),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<UsersProvider>(
            create: (context) => UsersProvider(context: context),
          ),
          ChangeNotifierProvider<EventsProvider>(
            create: (_) => EventsProvider(),
          ),
          ChangeNotifierProvider<FollowingProvider>(
            create: (context) => FollowingProvider(context: context),
          ),
          ChangeNotifierProvider<FavoritesProvider>(
            create: (context) => FavoritesProvider(context: context),
          ),
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationBloc>(
      create: (context) {
        return AuthenticationBloc(context: context)..add(AppStarted());
      },
      child: KeyboardDismissOnTap(
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
      ),
    );
  }
}
