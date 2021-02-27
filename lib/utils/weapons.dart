import 'package:flutter/material.dart';

class Weapons {
  static const _rootPath = 'assets/icons/weapons';

  static const greatSword = Weapon(
    id: 1,
    name: '大剣',
    iconFilePath: '$_rootPath/great_sword.png',
  );
  static const swordAndShield = Weapon(
    id: 2,
    name: '片手剣',
    iconFilePath: '$_rootPath/sword_and_shield.png',
  );
  static const dualBlades = Weapon(
    id: 3,
    name: '双剣',
    iconFilePath: '$_rootPath/dual_blades.png',
  );
  static const longSword = Weapon(
    id: 4,
    name: '太刀',
    iconFilePath: '$_rootPath/long_sword.png',
  );
  static const hammer = Weapon(
    id: 5,
    name: 'ハンマー',
    iconFilePath: '$_rootPath/hammer.png',
  );
  static const huntingHorn = Weapon(
    id: 6,
    name: '狩猟笛',
    iconFilePath: '$_rootPath/hunting_horn.png',
  );
  static const lance = Weapon(
    id: 7,
    name: 'ランス',
    iconFilePath: '$_rootPath/lance.png',
  );
  static const gunlance = Weapon(
    id: 8,
    name: 'ガンランス',
    iconFilePath: '$_rootPath/gunlance.png',
  );
  static const switchAxe = Weapon(
    id: 9,
    name: 'スラッシュアックス',
    iconFilePath: '$_rootPath/switch_axe.png',
  );
  static const chargeBlade = Weapon(
    id: 10,
    name: 'チャージアックス',
    iconFilePath: '$_rootPath/charge_blade.png',
  );
  static const insectGlaive = Weapon(
    id: 11,
    name: '操虫棍',
    iconFilePath: '$_rootPath/insect_glaive.png',
  );
  static const bow = Weapon(
    id: 12,
    name: '弓',
    iconFilePath: '$_rootPath/bow.png',
  );
  static const lightBowgun = Weapon(
    id: 13,
    name: 'ライトボウガン',
    iconFilePath: '$_rootPath/light_bowgun.png',
  );
  static const heavyBowgun = Weapon(
    id: 14,
    name: 'ヘビィボウガン',
    iconFilePath: '$_rootPath/heavy_bowgun.png',
  );

  static const all = [
    greatSword,
    swordAndShield,
    dualBlades,
    longSword,
    hammer,
    huntingHorn,
    lance,
    gunlance,
    switchAxe,
    chargeBlade,
    insectGlaive,
    bow,
    lightBowgun,
    heavyBowgun,
  ];

  static Weapon get({@required int id}) {
    if (id != null) {
      if (1 <= id && id <= all.length) {
        return all[id - 1];
      }
    }
    return null;
  }
}

class Weapon {
  const Weapon({
    @required this.id,
    @required this.name,
    @required this.iconFilePath,
  });

  final int id;
  final String name;
  final String iconFilePath;
}
