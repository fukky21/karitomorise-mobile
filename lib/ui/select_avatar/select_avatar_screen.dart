import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_circle_avatar.dart';
import '../../ui/components/custom_divider.dart';
import '../../util/app_colors.dart';

class SelectAvatarScreen extends StatelessWidget {
  static const route = '/select_avatar';
  static const _appBarTitle = 'プロフィール画像';

  // 表示順序を変えたいときはここを変更する
  static const _avatars = [
    AppUserAvatar.arzuros, // アオアシラ
    AppUserAvatar.agnaktor, // アグナコトル
    AppUserAvatar.azureRathalos, // リオレウス亜種
    AppUserAvatar.balefulGigginox, // ギギネブラ亜種
    AppUserAvatar.akantor, // アカムトルム
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(context, title: _appBarTitle),
      body: Scrollbar(
        child: ListView.separated(
          itemBuilder: (context, index) {
            return Ink(
              decoration: const BoxDecoration(color: AppColors.grey20),
              child: ListTile(
                leading: CustomCircleAvatar(
                  filePath: _avatars[index].filePath,
                  radius: 25,
                ),
                title: Text(_avatars[index].name),
                onTap: () => Navigator.of(context).pop(_avatars[index]),
              ),
            );
          },
          separatorBuilder: (context, _) => CustomDivider(),
          itemCount: _avatars.length,
        ),
      ),
    );
  }
}
