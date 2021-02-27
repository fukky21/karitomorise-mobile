import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../blocs/authentication_bloc/index.dart';
import '../../widgets/tabs/index.dart';

class StartScreen extends StatefulWidget {
  static const route = '/';

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    SearchTab(),
    ChatTab(),
    EventTab(),
    NotificationTab(),
    MyPageTab(),
  ];

  @override
  Widget build(BuildContext context) {
    const _iconSize = 20.0;

    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state == null || state is AuthenticationInProgress) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Scaffold(
          body: _tabs[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                  FontAwesomeIcons.search,
                  size: _iconSize,
                ),
                label: 'さがす',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  FontAwesomeIcons.solidComment,
                  size: _iconSize,
                ),
                label: 'チャット',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  FontAwesomeIcons.users,
                  size: _iconSize,
                ),
                label: '募集',
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
            type: BottomNavigationBarType.fixed,
          ),
        );
      },
    );
  }
}
