import 'package:flutter/material.dart';

import '../../utils/index.dart';
import '../../widgets/components/index.dart';

class SelectWeaponScreen extends StatelessWidget {
  static const route = 'select_weapon';
  static const _appBarTitle = 'メイン武器';

  static const _weapons = Weapons.all;

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
                leading: Image.asset(
                  _weapons[index].iconFilePath,
                  width: 50,
                  height: 50,
                ),
                title: Text(_weapons[index].name),
                onTap: () => Navigator.of(context).pop(_weapons[index]),
              ),
            );
          },
          separatorBuilder: (context, _) => CustomDivider(),
          itemCount: _weapons.length,
        ),
      ),
    );
  }
}
