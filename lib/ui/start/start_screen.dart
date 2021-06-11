import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../store.dart';
import '../../ui/basic_usage/basic_usage_screen.dart';
import '../../ui/error/error_screen.dart';
import '../../ui/home/home_screen.dart';
import '../../ui/mypage/mypage_screen.dart';
import '../../ui/notification/notification_screen.dart';
import '../../ui/search/search_screen.dart';
import '../../ui/terms_of_service/terms_of_service_screen.dart';
import '../../util/app_colors.dart';
import 'start_view_model.dart';

class StartScreen extends StatefulWidget {
  static const route = '/';

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  static const _iconSize = 20.0;

  final List<Widget> _tabs = [
    HomeScreen(),
    SearchScreen(),
    NotificationScreen(),
    MypageScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FlutterAppBadger.removeBadge();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // アプリがforegroundに復帰したときにバッジを削除する
      FlutterAppBadger.removeBadge();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StartViewModel(
        store: context.read<Store>(),
      )..init(),
      child: Consumer<StartViewModel>(
        builder: (context, viewModel, child) {
          final state = viewModel.getState() ?? StartScreenLoading();

          if (state is StartScreenLoadFailure) {
            return ErrorScreen();
          }

          if (state is StartScreenLoadSuccess) {
            final hasAgreedToTermsOfService = state.hasAgreedToTermsOfService;

            if (!hasAgreedToTermsOfService) {
              // はじめてアプリを起動したとき、利用規約画面と基本的な使い方画面を表示する
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await Navigator.pushNamed(context, TermsOfServiceScreen.route);
                await Navigator.pushNamed(context, BasicUsageScreen.route);
                await viewModel.init();
              });
            }
            return child;
          }

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
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
      ),
    );
  }
}
