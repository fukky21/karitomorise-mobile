import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import '../../stores/authentication_store.dart';
import '../../ui/home/home_screen.dart';
import '../../ui/mypage/mypage_screen.dart';
import '../../ui/notification/notification_screen.dart';
import '../../ui/search/search_screen.dart';
import '../../util/app_colors.dart';

class StartScreen extends StatefulWidget {
  static const route = '/';

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _currentIndex = 0;
  static const _iconSize = 20.0;

  final List<Widget> _tabs = [
    HomeScreen(),
    SearchScreen(),
    NotificationScreen(),
    MypageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthenticationStore>().getState();

    return ModalProgressHUD(
      inAsyncCall: authState is AuthenticationInProgress,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                FontAwesomeIcons.home,
                size: _iconSize,
              ),
              label: '',
              tooltip: 'ホーム',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                FontAwesomeIcons.search,
                size: _iconSize,
              ),
              label: '',
              tooltip: 'さがす',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                FontAwesomeIcons.solidBell,
                size: _iconSize,
              ),
              label: '',
              tooltip: 'お知らせ',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                FontAwesomeIcons.solidUser,
                size: _iconSize,
              ),
              label: '',
              tooltip: 'マイページ',
            ),
          ],
          backgroundColor: AppColors.grey10,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            if (index == 0 && _currentIndex == index) {
              // ホームタブ表示中にホームアイコンがタップされたとき
              homeScreenScrollToTop();
            }
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
