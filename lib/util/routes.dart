import 'package:flutter/material.dart';

import '../widgets/screens/index.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    try {
      switch (routeSettings.name) {
        case CreatePostScreen.route:
          final args = routeSettings.arguments as CreatePostScreenArguments;
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: true,
            builder: (_) => CreatePostScreen(args: args),
          );
        case EditUserScreen.route:
          final args = routeSettings.arguments as EditUserScreenArguments;
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: true,
            builder: (_) => EditUserScreen(args: args),
          );
        case SearchResultScreen.route:
          final args = routeSettings.arguments as SearchResultScreenArguments;
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (_) => SearchResultScreen(args: args),
          );
        case SearchScreen.route:
          final args = routeSettings.arguments as SearchScreenArguments;
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (_) => SearchScreen(args: args),
          );
        case SelectAvatarScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (_) => SelectAvatarScreen(),
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
        case ThreadScreen.route:
          final args = routeSettings.arguments as ThreadScreenArguments;
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: true,
            builder: (_) => ThreadScreen(args: args),
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
