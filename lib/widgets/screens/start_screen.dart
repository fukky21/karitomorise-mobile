import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../blocs/authentication_bloc/index.dart';
import '../../utils/index.dart';
import '../../widgets/tabs/index.dart';

class StartScreen extends StatefulWidget {
  static const route = '/';

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    HomeTab(),
    SearchTab(),
    FavoriteTab(),
    NotificationTab(),
    MyPageTab(),
  ];

  @override
  Widget build(BuildContext context) {
    const _iconSize = 20.0;

    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state == null || state is AuthenticationInProgress) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Scaffold(
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
                label: 'ホーム',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  FontAwesomeIcons.search,
                  size: _iconSize,
                ),
                label: 'さがす',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  FontAwesomeIcons.solidHeart,
                  size: _iconSize,
                ),
                label: 'お気に入り',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  FontAwesomeIcons.solidBell,
                  size: _iconSize,
                ),
                label: 'お知らせ',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  FontAwesomeIcons.solidUser,
                  size: _iconSize,
                ),
                label: 'マイページ',
              ),
            ],
            backgroundColor: AppColors.grey10,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              if (index == 0 && _currentIndex == index) {
                // ホームタブ表示中にホームアイコンがタップされたとき
                homeTabScrollToTop();
              }
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        );
      },
    );
  }
}
