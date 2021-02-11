import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../blocs/global_blocs/authentication_bloc/index.dart';
import '../../blocs/global_blocs/cubits/index.dart';
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
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, authState) {
        if (authState is AuthenticationSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await BlocProvider.of<FollowingCubit>(context).load();
            await BlocProvider.of<LikedEventsCubit>(context).load();
            await BlocProvider.of<UserCubit>(context).load();
          });
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
      },
    );
  }
}
