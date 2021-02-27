import 'package:flutter/material.dart';

import '../../models/index.dart';
import '../../utils/index.dart';
import '../../widgets/components/index.dart';

class SelectAvatarScreen extends StatelessWidget {
  static const route = 'select_avatar';
  static const _appBarTitle = 'プロフィール画像';

  static const _avatars = [
    UserAvatar.arzuros, // アオアシラ
    UserAvatar.agnaktor, // アグナコトル
    UserAvatar.azureRathalos, // リオレウス亜種
    UserAvatar.balefulGigginox, // ギギネブラ亜種
    UserAvatar.akantor, // アカムトルム
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
                  filePath: _avatars[index].iconFilePath,
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
