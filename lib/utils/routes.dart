import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../widgets/screens/index.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    try {
      switch (routeSettings.name) {
        case CreateEventScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: true,
            builder: (_) => CreateEventScreen(),
          );
        case EditUserScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: true,
            builder: (_) => EditUserScreen(),
          );
        case SearchScreen.route:
          final args = routeSettings.arguments as SearchScreenArguments;
          return PageTransition<dynamic>(
            settings: routeSettings,
            type: PageTransitionType.fade,
            child: SearchScreen(args: args),
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
        case ShowEventCommentsScreen.route:
          final args =
              routeSettings.arguments as ShowEventCommentsScreenArguments;
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (_) => ShowEventCommentsScreen(args: args),
          );
        case ShowEventScreen.route:
          final args = routeSettings.arguments as ShowEventScreenArguments;
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (_) => ShowEventScreen(args: args),
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