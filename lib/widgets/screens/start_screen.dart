import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
            icon: Icon(Icons.search),
            label: 'さがす',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.commentDots),
            label: 'チャット',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervisor_account_sharp),
            label: '募集',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'お知らせ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_sharp),
            label: 'マイページ',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
