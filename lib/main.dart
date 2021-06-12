import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'localizations/ja.dart';
import 'repositories/firebase_authentication_repository.dart';
import 'repositories/firebase_messaging_repository.dart';
import 'repositories/firebase_user_repository.dart';
import 'store.dart';
import 'util/routes.dart';
import 'util/style.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: '.env');

  // TODO(fukky21): 広告配信準備後に有効化する
  // await MobileAds.instance.initialize();

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
    ChangeNotifierProvider(
      create: (_) => Store(),
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
        debugShowCheckedModeBanner: false,
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
