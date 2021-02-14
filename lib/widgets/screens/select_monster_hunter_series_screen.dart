import 'package:flutter/material.dart';

import '../../models/index.dart';
import '../../utils/index.dart';
import '../../widgets/components/index.dart';

class SelectMonsterHunterSeriesScreen extends StatelessWidget {
  static const route = 'select_monster_hunter_series';
  static const _appBarTitle = '初プレイシリーズ';

  static const _series = MonsterHunterSeries.values;

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
                title: Text(_series[index].name),
                onTap: () => Navigator.of(context).pop(_series[index]),
              ),
            );
          },
          separatorBuilder: (context, _) => CustomDivider(),
          itemCount: _series.length,
        ),
      ),
    );
  }
}
