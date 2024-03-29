import 'package:flutter/material.dart';

import '../ui/basic_usage/basic_usage_screen.dart';
import '../ui/create_post/create_post_screen.dart';
import '../ui/delete_user/delete_user_screen.dart';
import '../ui/edit_email/edit_email_screen.dart';
import '../ui/edit_password/edit_password_screen.dart';
import '../ui/edit_user/edit_user_screen.dart';
import '../ui/error/error_screen.dart';
import '../ui/home/home_screen.dart';
import '../ui/mypage/mypage_screen.dart';
import '../ui/notification/notification_screen.dart';
import '../ui/reset_password/reset_password_screen.dart';
import '../ui/search/search_screen.dart';
import '../ui/search_result/search_result_screen.dart';
import '../ui/searching/searching_screen.dart';
import '../ui/select_avatar/select_avatar_screen.dart';
import '../ui/send_report/send_report_screen.dart';
import '../ui/show_license/show_license_screen.dart';
import '../ui/show_replies/show_replies_screen.dart';
import '../ui/show_thread/show_thread_screen.dart';
import '../ui/sign_in/sign_in_screen.dart';
import '../ui/sign_up/sign_up_screen.dart';
import '../ui/start/start_screen.dart';
import '../ui/terms_of_service/terms_of_service_screen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    try {
      switch (routeSettings.name) {
        case BasicUsageScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: true,
            builder: (_) => BasicUsageScreen(),
          );
        case CreatePostScreen.route:
          final args = routeSettings.arguments as CreatePostScreenArguments;
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: true,
            builder: (_) => CreatePostScreen(args: args),
          );
        case DeleteUserScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: true,
            builder: (_) => DeleteUserScreen(),
          );
        case EditEmailScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: true,
            builder: (_) => EditEmailScreen(),
          );
        case EditPasswordScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: true,
            builder: (_) => EditPasswordScreen(),
          );
        case EditUserScreen.route:
          final args = routeSettings.arguments as EditUserScreenArguments;
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: true,
            builder: (_) => EditUserScreen(args: args),
          );
        case HomeScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (_) => HomeScreen(),
          );
        case MypageScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (_) => MypageScreen(),
          );
        case NotificationScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (_) => NotificationScreen(),
          );
        case ResetPasswordScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (_) => ResetPasswordScreen(),
          );
        case SearchScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (_) => SearchScreen(),
          );
        case SearchResultScreen.route:
          final args = routeSettings.arguments as SearchResultScreenArguments;
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (_) => SearchResultScreen(args: args),
          );
        case SearchingScreen.route:
          final args = routeSettings.arguments as SearchingScreenArguments;
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (_) => SearchingScreen(args: args),
          );
        case SelectAvatarScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (_) => SelectAvatarScreen(),
          );
        case SendReportScreen.route:
          final args = routeSettings.arguments as SendReportScreenArguments;
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: true,
            builder: (_) => SendReportScreen(args: args),
          );
        case ShowLicenseScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (_) => ShowLicenseScreen(),
          );
        case ShowRepliesScreen.route:
          final args = routeSettings.arguments as ShowRepliesScreenArguments;
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: true,
            builder: (_) => ShowRepliesScreen(args: args),
          );
        case ShowThreadScreen.route:
          final args = routeSettings.arguments as ShowThreadScreenArguments;
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: true,
            builder: (_) => ShowThreadScreen(args: args),
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
        case TermsOfServiceScreen.route:
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: true,
            builder: (_) => TermsOfServiceScreen(),
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
