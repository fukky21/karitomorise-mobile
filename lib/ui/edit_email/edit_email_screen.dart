import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_raised_button.dart';
import '../../ui/components/custom_text_form_field.dart';
import '../../ui/components/scrollable_layout_builder.dart';
import '../../util/validations.dart';
import 'edit_email_view_model.dart';

class EditEmailScreen extends StatefulWidget {
  static const route = '/edit_email';

  @override
  _EditEmailScreenState createState() => _EditEmailScreenState();
}

class _EditEmailScreenState extends State<EditEmailScreen> {
  static const _appBarTitle = 'メールアドレスの変更';

  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController;
  TextEditingController _passwordController;
  String _currentEmail;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _currentEmail = '';
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditEmailViewModel()..init(),
      child: Consumer<EditEmailViewModel>(
        builder: (context, viewModel, _) {
          final state = viewModel.getState() ?? EditEmailScreenLoading();

          if (state is EditEmailScreenLoading) {
            return Scaffold(
              appBar: simpleAppBar(context, title: _appBarTitle),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is EditEmailScreenLoadFailure) {
            return Scaffold(
              appBar: simpleAppBar(context, title: _appBarTitle),
              body: const Center(
                child: Text('エラーが発生しました'),
              ),
            );
          }

          if (state is UpdateEmailFailure &&
              state.type == UpdateEmailFailureType.other) {
            return Scaffold(
              appBar: simpleAppBar(context, title: _appBarTitle),
              body: const Center(
                child: Text('エラーが発生しました'),
              ),
            );
          }

          if (state is UpdateEmailSuccess) {
            return Scaffold(
              appBar: simpleAppBar(context, title: _appBarTitle),
              body: const Center(
                child: Text('変更しました'),
              ),
            );
          }

          if (state is EditEmailScreenLoadSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _currentEmail = state.email;
              });
            });
          }

          return ModalProgressHUD(
            inAsyncCall: state is UpdateEmailInProgress,
            child: Scaffold(
              appBar: simpleAppBar(context, title: _appBarTitle),
              body: Form(
                key: _formKey,
                child: ScrollableLayoutBuilder(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 40),
                    child: Column(
                      children: [
                        const Text('現在のメールアドレス'),
                        const SizedBox(height: 20),
                        Text(
                          _currentEmail ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 40),
                        CustomTextFormField(
                          labelText: '新しいメールアドレス',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          errorText: _emailErrorText(state),
                          validator: _emailValidator,
                        ),
                        const SizedBox(height: 40),
                        CustomTextFormField(
                          labelText: 'パスワード',
                          controller: _passwordController,
                          obscureText: true,
                          errorText: _passwordErrorText(state),
                          validator: _passwordValidator,
                        ),
                        const SizedBox(height: 40),
                        CustomRaisedButton(
                          labelText: '変更する',
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            if (_formKey.currentState.validate()) {
                              await viewModel.updateEmail(
                                newEmail: _emailController.text,
                                password: _passwordController.text,
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

  String _emailErrorText(EditEmailScreenState state) {
    if (state is UpdateEmailFailure) {
      if (state.type == UpdateEmailFailureType.invalidEmail) {
        return 'このアドレスは不正です';
      }
      if (state.type == UpdateEmailFailureType.emailAlreadyInUse) {
        return 'このアドレスは登録済です';
      }
    }
    return null;
  }

  String _passwordErrorText(EditEmailScreenState state) {
    if (state is UpdateEmailFailure) {
      if (state.type == UpdateEmailFailureType.wrongPassword) {
        return 'パスワードが間違っています';
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

  String _passwordValidator(String password) {
    return Validations.blank(text: password);
  }
}
