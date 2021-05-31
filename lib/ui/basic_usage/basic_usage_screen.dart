import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../../ui/components/custom_raised_button.dart';
import '../../util/app_colors.dart';

class BasicUsageScreen extends StatefulWidget {
  static const route = '/basic_usage';

  @override
  _BasicUsageScreenState createState() => _BasicUsageScreenState();
}

class _BasicUsageScreenState extends State<BasicUsageScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  Widget _iconImage(BuildContext context, String imagePath) {
    return SafeArea(
      child: Image.asset(
        imagePath,
        width: MediaQuery.of(context).size.width * 0.5,
      ),
    );
  }

  Widget _screenImage(BuildContext context, String imagePath) {
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Container(
        width: width * 0.7,
        height: width * 0.7,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageDecoration = PageDecoration(
      titleTextStyle: Theme.of(context)
          .textTheme
          .headline5
          .copyWith(fontWeight: FontWeight.bold),
      descriptionPadding: const EdgeInsets.all(10),
      pageColor: AppColors.grey10,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: AppColors.grey10,
      globalFooter: SizedBox(
        width: double.infinity,
        height: 80,
        child: CustomRaisedButton(
          labelText: 'はじめる！',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      pages: [
        PageViewModel(
          title: 'ようこそ！',
          body: 'このアプリは、モンスターハンターライズで一緒に狩りを楽しむ仲間を募集できる掲示板アプリです。'
              'アプリの基本的な使い方について説明します。',
          image: _iconImage(context, 'assets/karitomorise_logo.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: '狩友を募集する',
          body: 'ホーム画面右下のペンマークのボタンから募集内容を投稿することができます。',
          image: _screenImage(
            context,
            'assets/images/basic_usage/basic_usage1.png',
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: '投稿に返信する',
          body: '気になる投稿に返信して、コミュニケーションをとることができます。',
          image: _screenImage(
            context,
            'assets/images/basic_usage/basic_usage2.png',
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: '投稿を検索する',
          body: '検索画面右上の検索アイコンからキーワード検索をすることができます。',
          image: _screenImage(
            context,
            'assets/images/basic_usage/basic_usage3.png',
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: '通知を受け取る',
          body: 'あなたの投稿に対して返信があったとき、プッシュ通知を受け取ることができます。\n\n'
              '※プッシュ通知を受け取るにはアプリにサインインする必要があります。',
          image: _screenImage(
            context,
            'assets/images/basic_usage/basic_usage4.png',
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: '注意事項',
          body: 'モンハンを心から楽しむために、相手に思いやりを持ち、マナーを守ってアプリのご利用をお願いいたします。\n\n'
              '※このアプリは株式会社カプコン様とは一切関係ありません。',
          image: _iconImage(
              context, 'assets/icons/apple_emoji/handshake_icon.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: 'さあ、はじめよう！',
          body: '',
          image: Container(),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => Navigator.of(context).pop(),
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: Text(
        'スキップ',
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
      next: Icon(
        Icons.arrow_forward,
        color: Theme.of(context).primaryColor,
      ),
      done: Text(
        '完了',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(15),
      controlsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      dotsDecorator: DotsDecorator(
        size: const Size(10, 10),
        color: AppColors.grey60,
        activeColor: Theme.of(context).primaryColor,
        activeSize: const Size(10, 10),
      ),
    );
  }
}
