import 'package:big_tip/big_tip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/screen_blocs/show_user_screen_bloc/dart/index.dart';
import '../../helpers/index.dart';
import '../../models/index.dart';
import '../../util/index.dart';
import '../../widgets/components/index.dart';

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
      create: (context) =>
          ShowUserScreenBloc()..add(Initialized(uid: args.uid)),
      child: BlocBuilder<ShowUserScreenBloc, ShowUserScreenState>(
        builder: (context, state) {
          if (state is Loading) {
            return Scaffold(
              appBar: simpleAppBar(context),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (state is LoadFailure) {
            if (state.errorType == LoadFailure.errorTypeUserAlreadyDeleted) {
              return Scaffold(
                appBar: simpleAppBar(context),
                body: const Center(
                  child: Text('このユーザーは削除されました'),
                ),
              );
            }
            return Scaffold(
              appBar: simpleAppBar(context),
              body: const Center(
                child: BigTip(
                  title: Text('エラーが発生しました'),
                  child: Icon(Icons.error_outline_sharp),
                ),
              ),
            );
          }
          if (state is LoadSuccess) {
            return _loadSuccessView(context, state);
          }
          return Container();
        },
      ),
    );
  }

  Widget _loadSuccessView(BuildContext context, LoadSuccess state) {
    final _screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: simpleAppBar(
        context,
        title: state?.user?.displayName ?? 'Unknown',
      ),
      body: ScrollableLayoutBuilder(
        body: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      CustomCircleAvatar(
                        filePath: state?.user?.avatarIconFilePath,
                        radius: 50,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        state?.user?.displayName ?? 'Unknown',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buttonSpace(state.editable),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(state?.user?.biography ?? ''),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _countPanel(
                            context,
                            title: '作成した募集',
                            count: 30, // TODO(Fukky21): 作成した募集数を取得する
                            size: _screenWidth * 0.25,
                            onTap: () {
                              // TODO(Fukky21): 募集一覧画面へ遷移する
                            },
                          ),
                          _countPanel(
                            context,
                            title: 'フォロー中',
                            count: 30, // TODO(Fukky21): フォロー数を取得する
                            size: _screenWidth * 0.25,
                            onTap: () {
                              // TODO(Fukky21): フォロー/フォロワー画面へ遷移する
                            },
                          ),
                          _countPanel(
                            context,
                            title: 'フォロワー',
                            count: 30, // TODO(Fukky21): フォロワー数を取得する
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
                _mainWeaponCell(state?.user),
                CustomDivider(),
                _firstPlayedSeriesCell(state?.user),
                CustomDivider(),
                _userCreatedAtCell(state?.user),
                CustomDivider(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonSpace(bool editable) {
    const _width = 115.0;
    const _height = 35.0;
    const _fontSize = 13.0;
    if (editable) {
      return CustomOutlineButton(
        width: _width,
        height: _height,
        fontSize: _fontSize,
        labelText: '編集する',
        onPressed: () {},
      );
    }
    return CustomOutlineButton(
      width: _width,
      height: _height,
      fontSize: _fontSize,
      labelText: 'フォローする',
      onPressed: () {},
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
          user?.mainWeaponType != null
              ? Row(
                  children: [
                    Image.asset(
                      user?.mainWeaponIconFilePath,
                      width: 50,
                      height: 50,
                    ),
                    Text(user?.mainWeaponName),
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
              child: Text(
                user?.firstPlayedSeriesName ?? '未選択',
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userCreatedAtCell(AppUser user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('利用開始日'),
          Text(getYMDString(user?.createdAt)),
        ],
      ),
    );
  }
}
