import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_raised_button.dart';
import '../../ui/components/custom_text_form_field.dart';
import '../../ui/components/scrollable_layout_builder.dart';
import '../../util/validations.dart';
import 'send_report_view_model.dart';

class SendReportScreenArguments {
  SendReportScreenArguments({@required this.postNumber});

  final int postNumber;
}

class SendReportScreen extends StatefulWidget {
  const SendReportScreen({@required this.args});

  static const route = '/send_report';
  final SendReportScreenArguments args;

  @override
  _SendReportScreenState createState() => _SendReportScreenState();
}

class _SendReportScreenState extends State<SendReportScreen> {
  final _appBarTitle = '通報する';
  final _formKey = GlobalKey<FormState>();
  TextEditingController _reportController;
  final _reportMaxLength = 100;

  @override
  void initState() {
    super.initState();
    _reportController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _reportController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SendReportViewModel(),
      child: Consumer<SendReportViewModel>(
        builder: (context, viewModel, _) {
          final state = viewModel.getState();

          if (state is SendReportFailure) {
            return Scaffold(
              appBar: simpleAppBar(context, title: _appBarTitle),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('エラーが発生しました'),
                      const SizedBox(height: 30),
                      CustomRaisedButton(
                        labelText: 'とじる',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state is SendReportSuccess) {
            return Scaffold(
              appBar: simpleAppBar(context, title: _appBarTitle),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('レポートを送信しました'),
                      const SizedBox(height: 10),
                      const Text('内容を確認し、不適切と判断された場合は投稿を削除いたします。'),
                      const SizedBox(height: 30),
                      CustomRaisedButton(
                        labelText: 'とじる',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ModalProgressHUD(
            inAsyncCall: state is SendReportInProgress,
            child: Scaffold(
              appBar: simpleAppBar(context, title: _appBarTitle),
              body: Form(
                key: _formKey,
                child: ScrollableLayoutBuilder(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 30,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('通報する投稿番号:'),
                            const SizedBox(width: 5),
                            Text(
                              '${widget?.args?.postNumber}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Text('通報理由を入力してください'),
                        const SizedBox(height: 15),
                        CustomTextFormField(
                          controller: _reportController,
                          maxLength: _reportMaxLength,
                          maxLines: 10,
                          validator: _reportValidator,
                        ),
                        const SizedBox(height: 30),
                        CustomRaisedButton(
                          labelText: '送信する',
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            if (_formKey.currentState.validate()) {
                              await viewModel.sendReport(
                                report: _reportController.text,
                                postNumber: widget?.args?.postNumber,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _reportValidator(String text) {
    final errorMessages = <String>[
      Validations.blank(text: text),
      Validations.maxLength(text: text, maxLength: _reportMaxLength),
    ];
    for (final errorMessage in errorMessages) {
      if (errorMessage != null) {
        return errorMessage;
      }
    }
    return null;
  }
}
