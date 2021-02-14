import 'package:flutter/material.dart';

import '../widgets/screens/index.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    try {
      switch (routeSettings.name) {
        case EditUserScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: true,
            builder: (_) => EditUserScreen(),
          );
        case SelectAvatarScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (_) => SelectAvatarScreen(),
          );
        case SelectMonsterHunterSeriesScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (_) => SelectMonsterHunterSeriesScreen(),
          );
        case SelectWeaponScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (_) => SelectWeaponScreen(),
          );
        case ShowUserScreen.route:
          final args = routeSettings.arguments as ShowUserScreenArguments;
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (_) => ShowUserScreen(args: args),
          );
        case SignInScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: true,
            builder: (_) => SignInScreen(),
          );
        case SignUpScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (_) => SignUpScreen(),
          );
        case StartScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (_) => StartScreen(),
          );
        default:
          return errorRoute(routeSettings);
      }
    } on Exception catch (_) {
      return errorRoute(routeSettings);
    }
  }

  static Route<dynamic> errorRoute(RouteSettings routeSettings) {
    return MaterialPageRoute<dynamic>(
      settings: routeSettings,
      builder: (_) => ErrorScreen(),
    );
  }
}
