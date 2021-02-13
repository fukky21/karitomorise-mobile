import 'package:flutter/material.dart';

import '../../helpers/index.dart';
import '../../models/index.dart';
import '../../util/index.dart';
import '../../widgets/components/index.dart';

class ShowUserScreen extends StatelessWidget {
  static const route = '/show_user';

  @override
  Widget build(BuildContext context) {
    final _screenWidth = MediaQuery.of(context).size.width;

    final _user = AppUser(
      id: 'tmp_id',
      displayName: '無名のハンター',
      biography:
          'これは自己紹介です。これは自己紹介です。これは自己紹介です。これは自己紹介です。これは自己紹介です。これは自己紹介です。これは自己紹介です。これは自己紹介です。',
      avatarType: 4,
      mainWeaponType: 3,
      firstPlayedSeriesType: 8,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Widget _countPanel({
      @required String title,
      @required int count,
      @required void Function() onTap,
    }) {
      return Material(
        color: AppColors.transparent,
        child: InkWell(
          child: SizedBox(
            width: _screenWidth * 0.25,
            height: _screenWidth * 0.25,
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

    return Scaffold(
      appBar: simpleAppBar(context, title: _user.displayName),
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
                        filePath: _user.avatarIconFilePath,
                        radius: 50,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _user.displayName ?? 'Unknown',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomOutlineButton(
                            width: 115,
                            height: 35,
                            fontSize: 13,
                            labelText: 'フォローする',
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(_user.biography ?? ''),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _countPanel(
                            title: '作成した募集',
                            count: 30,
                            onTap: () {
                              // TODO(Fukky21): 募集一覧画面へ遷移する
                            },
                          ),
                          _countPanel(
                            title: 'フォロー中',
                            count: 30,
                            onTap: () {
                              // TODO(Fukky21): フォロー/フォロワー画面へ遷移する
                            },
                          ),
                          _countPanel(
                            title: 'フォロワー',
                            count: 30,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('メイン武器'),
                      Row(
                        children: [
                          Image.asset(
                            _user.mainWeaponIconFilePath,
                            width: 50,
                            height: 50,
                          ),
                          Text(_user.mainWeaponName),
                        ],
                      ),
                    ],
                  ),
                ),
                CustomDivider(),
                Container(
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
                            _user.firstPlayedSeriesName,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomDivider(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('利用開始日'),
                      Text(getYMDString(_user.createdAt)),
                    ],
                  ),
                ),
                CustomDivider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
