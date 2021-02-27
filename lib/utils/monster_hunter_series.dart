import 'package:flutter/material.dart';

enum MonsterHunterSeries {
  mh,
  mhg,
  mh2,
  mhp,
  mhp2,
  mhp2g,
  mh3,
  mhp3,
  mh3g,
  mh4,
  mh4g,
  mhx,
  mhxx,
  mhw,
  mhr,
}

extension MonsterHunterSeriesExtension on MonsterHunterSeries {
  static final _ids = {
    MonsterHunterSeries.mh: 1,
    MonsterHunterSeries.mhg: 2,
    MonsterHunterSeries.mh2: 3,
    MonsterHunterSeries.mhp: 4,
    MonsterHunterSeries.mhp2: 5,
    MonsterHunterSeries.mhp2g: 6,
    MonsterHunterSeries.mh3: 7,
    MonsterHunterSeries.mhp3: 8,
    MonsterHunterSeries.mh3g: 9,
    MonsterHunterSeries.mh4: 10,
    MonsterHunterSeries.mh4g: 11,
    MonsterHunterSeries.mhx: 12,
    MonsterHunterSeries.mhxx: 13,
    MonsterHunterSeries.mhw: 14,
    MonsterHunterSeries.mhr: 15,
  };
  int get id => _ids[this];

  static final _names = {
    MonsterHunterSeries.mh: 'モンスターハンター',
    MonsterHunterSeries.mhg: 'モンスターハンターG',
    MonsterHunterSeries.mh2: 'モンスターハンター2',
    MonsterHunterSeries.mhp: 'モンスターハンターポータブル',
    MonsterHunterSeries.mhp2: 'モンスターハンターポータブル 2nd',
    MonsterHunterSeries.mhp2g: 'モンスターハンターポータブル 2nd G',
    MonsterHunterSeries.mh3: 'モンスターハンター3',
    MonsterHunterSeries.mhp3: 'モンスターハンターポータブル 3rd',
    MonsterHunterSeries.mh3g: 'モンスターハンター3G',
    MonsterHunterSeries.mh4: 'モンスターハンター4',
    MonsterHunterSeries.mh4g: 'モンスターハンター4G',
    MonsterHunterSeries.mhx: 'モンスターハンタークロス',
    MonsterHunterSeries.mhxx: 'モンスターハンターダブルクロス',
    MonsterHunterSeries.mhw: 'モンスターハンター：ワールド',
    MonsterHunterSeries.mhr: 'モンスターハンターライズ',
  };
  String get name => _names[this];
}

MonsterHunterSeries getMonsterHunterSeries({@required int id}) {
  for (final series in MonsterHunterSeries.values) {
    if (series.id == id) {
      return series;
    }
  }
  return null;
}
