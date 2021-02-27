import 'package:flutter/material.dart';

import '../utils/index.dart';

class AppUser {
  AppUser({
    this.id,
    this.displayName,
    this.biography,
    this.avatar,
    this.mainWeapon,
    this.firstPlayedSeries,
    this.createdEventCount,
    this.followingCount,
    this.followerCount,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String displayName;
  String biography;
  UserAvatar avatar;
  Weapon mainWeapon;
  MonsterHunterSeries firstPlayedSeries;
  int createdEventCount;
  int followingCount;
  int followerCount;
  DateTime createdAt;
  DateTime updatedAt;
}

enum UserAvatar {
  agnaktor,
  akantor,
  arzuros,
  azureRathalos,
  balefulGigginox,
}

extension UserAvatarExtension on UserAvatar {
  static final _ids = {
    UserAvatar.agnaktor: 1,
    UserAvatar.akantor: 2,
    UserAvatar.arzuros: 3,
    UserAvatar.azureRathalos: 4,
    UserAvatar.balefulGigginox: 5,
  };
  int get id => _ids[this];

  static final _names = {
    UserAvatar.agnaktor: 'アグナコトル',
    UserAvatar.akantor: 'アカムトルム',
    UserAvatar.arzuros: 'アオアシラ',
    UserAvatar.azureRathalos: 'リオレウス亜種',
    UserAvatar.balefulGigginox: 'ギギネブラ亜種',
  };
  String get name => _names[this];

  static const _rootPath = 'assets/icons/monsters';
  static final _iconFilePaths = {
    UserAvatar.agnaktor: '$_rootPath/agnaktor.png',
    UserAvatar.akantor: '$_rootPath/akantor.png',
    UserAvatar.arzuros: '$_rootPath/arzuros.png',
    UserAvatar.azureRathalos: '$_rootPath/azure_rathalos.png',
    UserAvatar.balefulGigginox: '$_rootPath/baleful_gigginox.png',
  };
  String get iconFilePath => _iconFilePaths[this];
}

UserAvatar getUserAvatar({@required int id}) {
  for (final avatar in UserAvatar.values) {
    if (avatar.id == id) {
      return avatar;
    }
  }
  return null;
}
