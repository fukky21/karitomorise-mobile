import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../blocs/show_user_screen_bloc/index.dart';
import '../../models/index.dart';
import '../../providers/index.dart';
import '../../utils/index.dart';
import '../../widgets/components/index.dart';
import 'edit_user_screen.dart';

class ShowUserScreenArguments {
  ShowUserScreenArguments({@required this.uid});

  final String uid;
}

class ShowUserScreen extends StatelessWidget {
  const ShowUserScreen({@required this.args});

  static const route = '/show_user';
  final ShowUserScreenArguments args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShowUserScreenBloc>(
      create: (context) => ShowUserScreenBloc(
        context: context,
      )..add(Initialized(uid: args.uid)),
      child: BlocBuilder<ShowUserScreenBloc, ShowUserScreenState>(
        builder: (context, state) {
          if (state is InitializeInProgress) {
            return Scaffold(
              appBar: simpleAppBar(context),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (state is InitializeFailure) {
            return _userNotFoundView(context);
          }
          if (state is InitializeSuccess) {
            return _loadSuccessView(context);
          }
          return Container();
        },
      ),
    );
  }

  Widget _userNotFoundView(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(context),
      body: const Center(
        child: Text('このユーザーは表示できません'),
      ),
    );
  }

  Widget _loadSuccessView(BuildContext context) {
    final _screenWidth = MediaQuery.of(context).size.width;

    return Consumer<UsersProvider>(
      builder: (context, provider, _) {
        final _user = provider.get(args.uid);
        if (_user == null) {
          return _userNotFoundView(context);
        }
        return RefreshIndicator(
          onRefresh: () async {
            BlocProvider.of<ShowUserScreenBloc>(context).add(
              Initialized(uid: args.uid),
            );
          },
          child: Scaffold(
            appBar: simpleAppBar(
              context,
              title: _user.displayName ?? 'Unknown',
            ),
            body: ScrollableLayoutBuilder(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          children: [
                            CustomCircleAvatar(
                              filePath: _user.avatarType?.iconFilePath,
                              radius: 50,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _user.displayName ?? 'Unknown',
                              style: Theme.of(context).textTheme.headline6,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buttonSpace(context, _user),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(_user.biography ?? ''),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _countPanel(
                                  context,
                                  title: '作成した募集',
                                  count: _user.createdEventCount ?? 0,
                                  size: _screenWidth * 0.25,
                                  onTap: () {
                                    // TODO(Fukky21): 募集一覧画面へ遷移する
                                  },
                                ),
                                _countPanel(
                                  context,
                                  title: 'フォロー中',
                                  count: _user.followingCount ?? 0,
                                  size: _screenWidth * 0.25,
                                  onTap: () {
                                    // TODO(Fukky21): フォロー/フォロワー画面へ遷移する
                                  },
                                ),
                                _countPanel(
                                  context,
                                  title: 'フォロワー',
                                  count: _user.followerCount ?? 0,
                                  size: _screenWidth * 0.25,
                                  onTap: () {
                                    // TODO(Fukky21): フォロー/フォロワー画面へ遷移する
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        margin: const EdgeInsets.only(bottom: 5),
                        child: const Text(
                          '基本情報',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      CustomDivider(),
                      _mainWeaponCell(_user),
                      CustomDivider(),
                      _firstPlayedSeriesCell(_user),
                      CustomDivider(),
                      _startDateCell(_user),
                      CustomDivider(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buttonSpace(BuildContext context, AppUser user) {
    const _width = 115.0;
    const _height = 35.0;

    return Consumer<CurrentUserProvider>(
      builder: (context, provider, _) {
        final _currentUser = provider.currentUser;
        if (_currentUser == null) {
          return Container();
        } else {
          if (_currentUser.uid == args.uid) {
            return CustomOutlineButton(
              labelText: '編集する',
              width: _width,
              height: _height,
              onPressed: () {
                Navigator.pushNamed(context, EditUserScreen.route);
              },
            );
          }
          return FollowUserButton(user: user, width: _width, height: _height);
        }
      },
    );
  }

  Widget _countPanel(
    BuildContext context, {
    @required String title,
    @required int count,
    @required double size,
    @required void Function() onTap,
  }) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        child: SizedBox(
          width: size,
          height: size,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$count',
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(title, style: Theme.of(context).textTheme.caption),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _mainWeaponCell(AppUser user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('メイン武器'),
          user?.mainWeapon != null
              ? Row(
                  children: [
                    Image.asset(
                      user.mainWeapon.iconFilePath,
                      width: 50,
                      height: 50,
                    ),
                    Text(user.mainWeapon.name),
                  ],
                )
              : const Text('未選択'),
        ],
      ),
    );
  }

  Widget _firstPlayedSeriesCell(AppUser user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('初プレイシリーズ'),
          Flexible(
            child: Container(
              padding: const EdgeInsets.only(left: 15),
              child: AutoSizeText(
                user?.firstPlayedSeries?.name ?? '未選択',
                textAlign: TextAlign.right,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _startDateCell(AppUser user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('利用開始日'),
          Text(user?.createdAt?.toYMDString()),
        ],
      ),
    );
  }
}
