import 'package:flutter/material.dart';

import '../../models/index.dart';
import '../../utils/index.dart';
import '../../widgets/components/index.dart';

class SelectAvatarScreen extends StatelessWidget {
  static const route = 'select_avatar';
  static const _appBarTitle = 'プロフィール画像';

  static const _avatarTypes = [
    AvatarType.arzuros, // アオアシラ
    AvatarType.agnaktor, // アグナコトル
    AvatarType.azureRathalos, // リオレウス亜種
    AvatarType.balefulGigginox, // ギギネブラ亜種
    AvatarType.akantor, // アカムトルム
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
                  filePath: _avatarTypes[index].iconFilePath,
                  radius: 25,
                ),
                title: Text(_avatarTypes[index].name),
                onTap: () => Navigator.of(context).pop(_avatarTypes[index]),
              ),
            );
          },
          separatorBuilder: (context, _) => CustomDivider(),
          itemCount: _avatarTypes.length,
        ),
      ),
    );
  }
}
