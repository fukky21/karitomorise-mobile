import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../../stores/signed_in_user_store.dart';
import 'localizations/ja.dart';
import 'models/app_user.dart';
import 'repositories/firebase_authentication_repository.dart';
import 'repositories/firebase_messaging_repository.dart';
import 'repositories/firebase_user_repository.dart';
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

  final authRepository = FirebaseAuthenticationRepository();
  final messagingRepository = FirebaseMessagingRepository();
  final userRepository = FirebaseUserRepository();

  // サインインしていない場合は匿名でサインインする
  final currentUser = authRepository.getCurrentUser();
  if (currentUser == null) {
    await authRepository.signInAnonymously();
  }

  AppUser user;
  if (currentUser != null && !currentUser.isAnonymous) {
    user = await userRepository.getUser(id: currentUser.uid);
    if (user == null) {
      throw Exception('User document is not found.');
    }
  } else {
    user = AppUser(
      id: null,
      name: '名無しのハンター',
      avatar: AppUserAvatar.unknown,
    );
  }

  await messagingRepository.requestPermission();
  await messagingRepository.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: false,
    sound: true,
  );

  final token = await messagingRepository.getToken();
  await userRepository.addToken(token: token);
  messagingRepository
      .getTokenRefreshStream()
      .listen((token) => userRepository.addToken(token: token));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SignedInUserStore()..setUser(user: user),
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
