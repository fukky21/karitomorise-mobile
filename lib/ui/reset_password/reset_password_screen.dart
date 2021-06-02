import 'package:big_tip/big_tip.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_raised_button.dart';
import '../../ui/components/custom_text_form_field.dart';
import '../../ui/components/scrollable_layout_builder.dart';
import '../../ui/reset_password/reset_password_view_model.dart';
import '../../util/validations.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const route = '/reset_password';

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _appBarTitle = 'パスワードを忘れた';
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResetPasswordViewModel(),
      child: Consumer<ResetPasswordViewModel>(
        builder: (context, viewModel, _) {
          final state = viewModel.getState();

          if (state is SendPasswordResetEmailFailure &&
              state.type == SendPasswordResetEmailFailureType.other) {
            return Scaffold(
              appBar: simpleAppBar(context, title: _appBarTitle),
              body: const BigTip(
                title: Text('エラーが発生しました'),
                child: Icon(Icons.error_outline_sharp),
              ),
            );
          }

          if (state is SendPasswordResetEmailSuccess) {
            return Scaffold(
              appBar: simpleAppBar(context, title: _appBarTitle),
              body: Padding(
                padding: const EdgeInsets.all(15),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('ご指定のアドレスにパスワード変更確認メールを送信しました。'),
                      const SizedBox(height: 30),
                      CustomRaisedButton(
                        labelText: '戻る',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ModalProgressHUD(
            inAsyncCall: state is SendPasswordResetEmailInProgress,
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
                    child: Center(
                      child: Column(
                        children: [
                          const Text(
                            'パスワード再設定メールを送信します。以下に登録済のメールアドレスを入力してください。',
                          ),
                          const SizedBox(height: 30),
                          CustomTextFormField(
                            labelText: 'メールアドレス',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            errorText: _emailErrorText(state),
                            validator: _emailValidator,
                          ),
                          const SizedBox(height: 50),
                          CustomRaisedButton(
                            labelText: '送信する',
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              if (_formKey.currentState.validate()) {
                                await viewModel.sendPasswordResetEmail(
                                  email: _emailController.text,
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
            ),
          );
        },
      ),
    );
  }

  String _emailErrorText(ResetPasswordScreenState state) {
    if (state is SendPasswordResetEmailFailure) {
      if (state.type == SendPasswordResetEmailFailureType.invalidEmail) {
        return 'このアドレスは不正です';
      }
      if (state.type == SendPasswordResetEmailFailureType.userNotFound) {
        return 'このアドレスは登録されていません';
      }
    }
    return null;
  }

  String _emailValidator(String email) {
    final errorMessages = <String>[
      Validations.blank(text: email),
      Validations.emailFormat(email: email),
    ];
    for (final errorMessage in errorMessages) {
      if (errorMessage != null) {
        return errorMessage;
      }
    }
    return null;
  }
}
