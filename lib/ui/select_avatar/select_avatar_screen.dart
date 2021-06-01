import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_circle_avatar.dart';
import '../../ui/components/custom_divider.dart';
import '../../util/app_colors.dart';

class SelectAvatarScreen extends StatelessWidget {
  static const route = '/select_avatar';
  static const _appBarTitle = 'プロフィール画像';

  // 50音順
  static const _avatars = [
    AppUserAvatar.arzuros, // アオアシラ
    AppUserAvatar.akantor, // アカムトルム
    AppUserAvatar.agnaktor, // アグナコトル
    AppUserAvatar.glacialAgnaktor, // アグナコトル亜種
    AppUserAvatar.seltas, // アルセルタス
    AppUserAvatar.deviljho, // イビルジョー
    AppUserAvatar.yianKutKu, // イャンクック
    AppUserAvatar.blueYianKutKu, // イャンクック亜種
    AppUserAvatar.ukanlos, // ウカムルバス
    AppUserAvatar.uragaan, // ウラガンキン
    AppUserAvatar.steelUragaan, // ウラガンキン亜種
    AppUserAvatar.lagombi, // ウルクスス
    AppUserAvatar.gigginox, // ギギネブラ
    AppUserAvatar.balefulGigginox, // ギギネブラ亜種
    AppUserAvatar.kirin, // キリン
    AppUserAvatar.oroshiKirin, // キリン亜種
    AppUserAvatar.qurupeco, // クルペッコ
    AppUserAvatar.crimsonQurupeco, // クルペッコ亜種
    AppUserAvatar.seltasQueen, // ゲネル・セルタス
    AppUserAvatar.jhenMohran, // ジエン・モーラン
    AppUserAvatar.zinogre, // ジンオウガ
    AppUserAvatar.stygianZinogre, // ジンオウガ亜種
    AppUserAvatar.gobul, // チャナガブル
    AppUserAvatar.diablos, // ディアブロス
    AppUserAvatar.blackDiablos, // ディアブロス亜種
    AppUserAvatar.tigrex, // ティガレックス
    AppUserAvatar.bruteTigrex, // ティガレックス亜種
    AppUserAvatar.greatJaggi, // ドスジャギィ
    AppUserAvatar.greatBaggi, // ドスバギィ
    AppUserAvatar.bulldrome, // ドスファンゴ
    AppUserAvatar.greatWroggi, // ドスフロギィ
    AppUserAvatar.duramboros, // ドボルベルク
    AppUserAvatar.rustDuramboros, // ドボルベルク亜種
    AppUserAvatar.nibelsnarf, // ハプルボッカ
    AppUserAvatar.khezu, // フルフル
    AppUserAvatar.redKhezu, // フルフル亜種
    AppUserAvatar.barioth, // ベリオロス
    AppUserAvatar.sandBarioth, // ベリオロス亜種
    AppUserAvatar.barroth, // ボルボロス
    AppUserAvatar.jadeBarroth, // ボルボロス亜種
    AppUserAvatar.nargacuga, // ナルガクルガ
    AppUserAvatar.greenNargacuga, // ナルガクルガ亜種
    AppUserAvatar.rajang, // ラージャン
    AppUserAvatar.volvidon, // ラングロトラ
    AppUserAvatar.rathian, // リオレイア
    AppUserAvatar.pinkRathian, // リオレイア亜種
    AppUserAvatar.goldRathian, // リオレイア希少種
    AppUserAvatar.rathalos, // リオレウス
    AppUserAvatar.azureRathalos, // リオレウス亜種
    AppUserAvatar.silverRathalos, // リオレウス希少種
    AppUserAvatar.royalLudroth, // ロアルドロス
    AppUserAvatar.purpleLudroth, // ロアルドロス亜種
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
                  filePath: _avatars[index].filePath,
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
