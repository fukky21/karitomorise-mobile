import '../utils/index.dart';

class AppUser {
  AppUser({
    this.id,
    this.displayName,
    this.biography,
    this.avatarType,
    this.mainWeapon,
    this.firstPlayedSeries,
    this.createdEventCount,
    this.followingCount,
    this.followerCount,
    this.isFollowed,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String displayName;
  String biography;
  AvatarType avatarType;
  Weapon mainWeapon;
  MonsterHunterSeries firstPlayedSeries;
  int createdEventCount;
  int followingCount;
  int followerCount;
  bool isFollowed;
  DateTime createdAt;
  DateTime updatedAt;
}

enum AvatarType {
  agnaktor,
  akantor,
  arzuros,
  azureRathalos,
  balefulGigginox,
}

extension AvatarTypeExtension on AvatarType {
  static final _names = {
    AvatarType.agnaktor: 'アグナコトル',
    AvatarType.akantor: 'アカムトルム',
    AvatarType.arzuros: 'アオアシラ',
    AvatarType.azureRathalos: 'リオレウス亜種',
    AvatarType.balefulGigginox: 'ギギネブラ亜種',
  };
  String get name => _names[this];

  static const _rootPath = 'assets/icons/monsters';
  static final _iconFilePaths = {
    AvatarType.agnaktor: '$_rootPath/agnaktor.png',
    AvatarType.akantor: '$_rootPath/akantor.png',
    AvatarType.arzuros: '$_rootPath/arzuros.png',
    AvatarType.azureRathalos: '$_rootPath/azure_rathalos.png',
    AvatarType.balefulGigginox: '$_rootPath/baleful_gigginox.png',
  };
  String get iconFilePath => _iconFilePaths[this];
}

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
