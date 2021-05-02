import 'package:flutter/material.dart';

class AppUser {
  AppUser({
    @required this.id,
    @required this.name,
    @required this.avatar,
  });

  final String id;
  final String name;
  final AppUserAvatar avatar;
}

// TODO(fukky21): AppUserAvatarを追加する
enum AppUserAvatar {
  agnaktor,
  akantor,
  arzuros,
  azureRathalos,
  balefulGigginox,
  unknown,
}

extension AppUserAvatarExtension on AppUserAvatar {
  static final _idList = {
    AppUserAvatar.agnaktor: 1,
    AppUserAvatar.akantor: 2,
    AppUserAvatar.arzuros: 3,
    AppUserAvatar.azureRathalos: 4,
    AppUserAvatar.balefulGigginox: 5,
    AppUserAvatar.unknown: 6,
  };
  int get id => _idList[this];

  static final _names = {
    AppUserAvatar.agnaktor: 'アグナコトル',
    AppUserAvatar.akantor: 'アカムトルム',
    AppUserAvatar.arzuros: 'アオアシラ',
    AppUserAvatar.azureRathalos: 'リオレウス亜種',
    AppUserAvatar.balefulGigginox: 'ギギネブラ亜種',
    AppUserAvatar.unknown: 'Unknown',
  };
  String get name => _names[this];

  static const _path = 'assets/icons/monsters';
  static final _filePaths = {
    AppUserAvatar.agnaktor: '$_path/agnaktor.png',
    AppUserAvatar.akantor: '$_path/akantor.png',
    AppUserAvatar.arzuros: '$_path/arzuros.png',
    AppUserAvatar.azureRathalos: '$_path/azure_rathalos.png',
    AppUserAvatar.balefulGigginox: '$_path/baleful_gigginox.png',
    AppUserAvatar.unknown: '$_path/unknown.png',
  };
  String get filePath => _filePaths[this];
}

AppUserAvatar getAppUserAvatar({@required int id}) {
  for (final avatar in AppUserAvatar.values) {
    if (avatar.id == id) {
      return avatar;
    }
  }
  return AppUserAvatar.unknown;
}
