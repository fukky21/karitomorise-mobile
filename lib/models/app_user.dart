import '../util/app_icons.dart';

class AppUser {
  AppUser({
    this.id,
    this.displayName,
    this.biography,
    this.avatarType,
    this.mainWeaponType,
    this.firstPlayedSeriesType,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String displayName;
  String biography;
  int avatarType;
  int mainWeaponType;
  int firstPlayedSeriesType;
  DateTime createdAt;
  DateTime updatedAt;

  // avatarType
  static const avatarTypeAgnaktor = 1; // アグナコトル
  static const avatarTypeAkantor = 2; // アカムトルム
  static const avatarTypeArzuros = 3; // アオアシラ
  static const avatarTypeAzureRathalos = 4; // リオレウス亜種
  static const avatarTypeBalefulGigginox = 5; // ギギネブラ亜種

  // mainWeaponType
  static const mainWeaponTypeBow = 1; // 弓
  static const mainWeaponTypeChargeBlade = 2; // チャージアックス
  static const mainWeaponTypeDualBlades = 3; // 双剣
  static const mainWeaponTypeGreatSword = 4; // 大剣
  static const mainWeaponTypeGunlance = 5; // ガンランス
  static const mainWeaponTypeHammer = 6; // ハンマー
  static const mainWeaponTypeHeavyBowgun = 7; // ヘビィボウガン
  static const mainWeaponTypeHuntingHorn = 8; // 狩猟笛
  static const mainWeaponTypeInsectGlaive = 9; // 操虫棍
  static const mainWeaponTypeLance = 10; // ランス
  static const mainWeaponTypeLightBowgun = 11; // ライトボウガン
  static const mainWeaponTypeLongSword = 12; // 太刀
  static const mainWeaponTypeSwitchAxe = 13; // スラッシュアックス
  static const mainWeaponTypeSwordAndShield = 14; // 片手剣

  // firstPlayedSeriesType
  static const firstPlayedSeriesTypeMH = 1; // モンスターハンター
  static const firstPlayedSeriesTypeMHG = 2; // モンスターハンターG
  static const firstPlayedSeriesTypeMH2dos = 3; // モンスターハンター2(ドス)
  static const firstPlayedSeriesTypeMHP = 4; // モンスターハンターポータブル
  static const firstPlayedSeriesTypeMHP2 = 5; // モンスターハンターポータブル2nd
  static const firstPlayedSeriesTypeMHP2G = 6; // モンスターハンターポータブル2ndG
  static const firstPlayedSeriesTypeMH3 = 7; // モンスターハンター3(トライ)
  static const firstPlayedSeriesTypeMHP3 = 8; // モンスターハンターポータブル3rd
  static const firstPlayedSeriesTypeMH3G = 9; // モンスターハンター3(トライ)G
  static const firstPlayedSeriesTypeMH4 = 10; // モンスターハンター4
  static const firstPlayedSeriesTypeMH4G = 11; // モンスターハンター4G
  static const firstPlayedSeriesTypeMHX = 12; // モンスターハンタークロス
  static const firstPlayedSeriesTypeMHXX = 13; // モンスターハンターダブルクロス
  static const firstPlayedSeriesTypeMHW = 14; // モンスターハンター：ワールド
  static const firstPlayedSeriesTypeMHR = 15; // モンスターハンターライズ

  String get avatarIconFilePath {
    switch (avatarType) {
      case avatarTypeAgnaktor:
        return AppIcons.agnaktor;
      case avatarTypeAkantor:
        return AppIcons.akantor;
      case avatarTypeArzuros:
        return AppIcons.arzuros;
      case avatarTypeAzureRathalos:
        return AppIcons.azureRathalos;
      case avatarTypeBalefulGigginox:
        return AppIcons.balefulGigginox;
      default:
        return AppIcons.unknownMonster;
    }
  }

  String get mainWeaponIconFilePath {
    switch (mainWeaponType) {
      case mainWeaponTypeBow:
        return AppIcons.bow;
      case mainWeaponTypeChargeBlade:
        return AppIcons.chargeBlade;
      case mainWeaponTypeDualBlades:
        return AppIcons.dualBlades;
      case mainWeaponTypeGreatSword:
        return AppIcons.greatSword;
      case mainWeaponTypeGunlance:
        return AppIcons.gunlance;
      case mainWeaponTypeHammer:
        return AppIcons.hammer;
      case mainWeaponTypeHeavyBowgun:
        return AppIcons.heavyBowgun;
      case mainWeaponTypeHuntingHorn:
        return AppIcons.huntingHorn;
      case mainWeaponTypeInsectGlaive:
        return AppIcons.insectGlaive;
      case mainWeaponTypeLance:
        return AppIcons.lance;
      case mainWeaponTypeLightBowgun:
        return AppIcons.lightBowgun;
      case mainWeaponTypeLongSword:
        return AppIcons.longSword;
      case mainWeaponTypeSwitchAxe:
        return AppIcons.switchAxe;
      case mainWeaponTypeSwordAndShield:
        return AppIcons.swordAndShield;
      default:
        return AppIcons.emptyWeapon;
    }
  }

  String get mainWeaponName {
    switch (mainWeaponType) {
      case mainWeaponTypeBow:
        return '弓';
      case mainWeaponTypeChargeBlade:
        return 'チャージアックス';
      case mainWeaponTypeDualBlades:
        return '双剣';
      case mainWeaponTypeGreatSword:
        return '大剣';
      case mainWeaponTypeGunlance:
        return 'ガンランス';
      case mainWeaponTypeHammer:
        return 'ハンマー';
      case mainWeaponTypeHeavyBowgun:
        return 'ヘビィボウガン';
      case mainWeaponTypeHuntingHorn:
        return '狩猟笛';
      case mainWeaponTypeInsectGlaive:
        return '操虫棍';
      case mainWeaponTypeLance:
        return 'ランス';
      case mainWeaponTypeLightBowgun:
        return 'ライトボウガン';
      case mainWeaponTypeLongSword:
        return '太刀';
      case mainWeaponTypeSwitchAxe:
        return 'スラッシュアックス';
      case mainWeaponTypeSwordAndShield:
        return '片手剣';
      default:
        return '未選択';
    }
  }

  String get firstPlayedSeriesName {
    switch (firstPlayedSeriesType) {
      case firstPlayedSeriesTypeMH:
        return 'モンスターハンター';
      case firstPlayedSeriesTypeMHG:
        return 'モンスターハンターG';
      case firstPlayedSeriesTypeMH2dos:
        return 'モンスターハンター2(ドス)';
      case firstPlayedSeriesTypeMHP:
        return 'モンスターハンターポータブル';
      case firstPlayedSeriesTypeMHP2:
        return 'モンスターハンターポータブル2nd';
      case firstPlayedSeriesTypeMHP2G:
        return 'モンスターハンターポータブル2ndG';
      case firstPlayedSeriesTypeMH3:
        return 'モンスターハンター3(トライ)';
      case firstPlayedSeriesTypeMHP3:
        return 'モンスターハンターポータブル3rd';
      case firstPlayedSeriesTypeMH3G:
        return 'モンスターハンター3(トライ)G';
      case firstPlayedSeriesTypeMH4:
        return 'モンスターハンター4';
      case firstPlayedSeriesTypeMH4G:
        return 'モンスターハンター4G';
      case firstPlayedSeriesTypeMHX:
        return 'モンスターハンタークロス';
      case firstPlayedSeriesTypeMHXX:
        return 'モンスターハンターダブルクロス';
      case firstPlayedSeriesTypeMHW:
        return 'モンスターハンター：ワールド';
      case firstPlayedSeriesTypeMHR:
        return 'モンスターハンターライズ';
      default:
        return '未選択';
    }
  }
}
