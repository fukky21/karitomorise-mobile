import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import '../../ui/components/bullet_texts.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_raised_button.dart';
import '../../ui/components/custom_text_form_field.dart';
import '../../ui/components/scrollable_layout_builder.dart';
import '../../util/validations.dart';
import 'edit_password_view_model.dart';

class EditPasswordScreen extends StatefulWidget {
  static const route = '/edit_password';

  @override
  _EditPasswordScreenState createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<EditPasswordScreen> {
  static const _appBarTitle = 'パスワードの変更';
  static const _passwordMinLength = 8;
  static const _passwordMaxLength = 20;
  static const _passwordNotes = [
    '半角英子文字大文字数字をそれぞれ1種類以上使用してください',
    '$_passwordMinLength文字以上$_passwordMaxLength文字以内で入力してください',
  ];
  final _formKey = GlobalKey<FormState>();
  TextEditingController _currentPasswordController;
  TextEditingController _newPasswordController;
  TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditPasswordViewModel(),
      child: Consumer<EditPasswordViewModel>(
        builder: (context, viewModel, _) {
          final state = viewModel.getState();

          if (state is UpdatePasswordFailure &&
              state.type == UpdatePasswordFailureType.other) {
            return Scaffold(
              appBar: simpleAppBar(context, title: _appBarTitle),
              body: const Center(
                child: Text('エラーが発生しました'),
              ),
            );
          }

          if (state is UpdatePasswordSuccess) {
            return Scaffold(
              appBar: simpleAppBar(context, title: _appBarTitle),
              body: const Center(
                child: Text('変更しました'),
              ),
            );
          }

          return ModalProgressHUD(
            inAsyncCall: state is UpdatePasswordInProgress,
            child: Scaffold(
              appBar: simpleAppBar(context, title: _appBarTitle),
              body: Form(
                key: _formKey,
                child: ScrollableLayoutBuilder(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 40,
                    ),
                    child: Column(
                      children: [
                        CustomTextFormField(
                          labelText: '現在のパスワード',
                          controller: _currentPasswordController,
                          obscureText: true,
                          errorText: _currentPasswordErrorText(state),
                          validator: _currentPasswordValidator,
                        ),
                        const SizedBox(height: 30),
                        const BulletTexts(texts: _passwordNotes),
                        const SizedBox(height: 30),
                        CustomTextFormField(
                          labelText: '新しいパスワード',
                          controller: _newPasswordController,
                          obscureText: true,
                          errorText: _newPasswordErrorText(state),
                          validator: _newPasswordValidator,
                        ),
                        const SizedBox(height: 30),
                        CustomTextFormField(
                          labelText: '新しいパスワード(確認)',
                          controller: _confirmPasswordController,
                          obscureText: true,
                          validator: _confirmPasswordValidator,
                        ),
                        const SizedBox(height: 30),
                        CustomRaisedButton(
                          labelText: '変更する',
                          onPressed: () async {
                            await _updatePasswordEvent(
                              context,
                              viewModel: viewModel,
                            );
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

  Future<void> _updatePasswordEvent(
    BuildContext context, {
    @required EditPasswordViewModel viewModel,
  }) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState.validate()) {
      await viewModel.updatePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
    }
  }

  String _currentPasswordErrorText(EditPasswordScreenState state) {
    if (state is UpdatePasswordFailure &&
        state.type == UpdatePasswordFailureType.wrongPassword) {
      return 'パスワードが間違っています';
    }
    return null;
  }

  String _newPasswordErrorText(EditPasswordScreenState state) {
    if (state is UpdatePasswordFailure &&
        state.type == UpdatePasswordFailureType.weakPassword) {
      return 'パスワード強度が低いです';
    }
    return null;
  }

  String _currentPasswordValidator(String password) {
    return Validations.blank(text: password);
  }

  String _newPasswordValidator(String password) {
    final errorMessages = <String>[
      Validations.blank(text: password),
      Validations.rangeLength(
        text: password,
        minLength: _passwordMinLength,
        maxLength: _passwordMaxLength,
      ),
      Validations.passwordFormat(password: password),
    ];
    for (final errorMessage in errorMessages) {
      if (errorMessage != null) {
        return errorMessage;
      }
    }
    return null;
  }

  String _confirmPasswordValidator(String confirmPassword) {
    final newPassword = _newPasswordController.text;
    final errorMessages = <String>[
      Validations.blank(text: confirmPassword),
      Validations.confirmPassword(
        password: newPassword,
        confirmPassword: confirmPassword,
      ),
    ];
    for (final errorMessage in errorMessages) {
      if (errorMessage != null) {
        return errorMessage;
      }
    }
    return null;
  }
}
