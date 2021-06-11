import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../repositories/shared_preference_repository.dart';
import '../../ui/components/custom_divider.dart';
import '../../ui/components/custom_modal.dart';
import '../../ui/components/custom_raised_button.dart';
import '../../util/app_colors.dart';

class TermsOfServiceScreen extends StatefulWidget {
  static const route = '/terms_of_service';

  @override
  _TermsOfServiceScreenState createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  final _prefRepository = SharedPreferenceRepository();
  bool _agreed;

  @override
  void initState() {
    super.initState();
    _agreed = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: WebView(
                initialUrl: '${dotenv.env['HP_BASE_URL']}/terms_of_service',
              ),
            ),
            const SizedBox(height: 30),
            _termsOfServiceCell(),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomRaisedButton(
                labelText: '利用を開始する',
                onPressed: () async {
                  if (_agreed) {
                    try {
                      await _prefRepository.agreeToTermsOfService();
                      Navigator.of(context).pop();
                    } on Exception catch (e) {
                      debugPrint(e.toString());
                      showErrorModal(context, 'エラーが発生しました');
                    }
                  } else {
                    showErrorModal(context, '利用規約に同意していません');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _termsOfServiceCell() {
    return Column(
      children: [
        CustomDivider(),
        Container(
          color: AppColors.grey20,
          width: double.infinity,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 15),
                child: const Text('利用規約に同意する'),
              ),
              Container(
                padding: const EdgeInsets.only(right: 5),
                child: CupertinoSwitch(
                  value: _agreed,
                  onChanged: (value) {
                    setState(() {
                      _agreed = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        CustomDivider(),
      ],
    );
  }
}
