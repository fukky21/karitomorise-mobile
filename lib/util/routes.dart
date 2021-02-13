import 'package:flutter/material.dart';

import '../widgets/screens/index.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    try {
      switch (routeSettings.name) {
        case ShowUserScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (_) => ShowUserScreen(),
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
