import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../util/app_colors.dart';

class AdvertisingCell extends StatefulWidget {
  @override
  _AdvertisingCellState createState() => _AdvertisingCellState();
}

class _AdvertisingCellState extends State<AdvertisingCell> {
  BannerAd _ad;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();

    const flavor = String.fromEnvironment('FLAVOR');
    String adUnitId;
    if (flavor == 'staging' || flavor == 'production') {
      adUnitId = dotenv.env['GOOGLE_AD_UNIT_ID'];
    } else {
      // テスト用のサンプル広告ユニット
      adUnitId = 'ca-app-pub-3940256099942544/2934735716';
    }

    _ad = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.fullBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint(
            'Ad load failed (code=${error.code} message=${error.message})',
          );
        },
      ),
    );
    _ad.load();
  }

  @override
  void dispose() {
    _ad.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: AppColors.grey20,
      width: double.infinity,
      height: 180,
      child: Center(
        child:
            _isAdLoaded ? AdWidget(ad: _ad) : const CircularProgressIndicator(),
      ),
    );
  }
}
