import 'package:big_tip/big_tip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../blocs/sign_up_screen_bloc/index.dart';
import '../../utils/index.dart';
import '../../widgets/components/index.dart';

class SignUpScreen extends StatefulWidget {
  static const route = '/sign_up';

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static const _appBarTitle = 'アカウントを作成';
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _confirmPasswordController;
  TextEditingController _displayNameController;
  TapGestureRecognizer _recognizer;
  bool _isAgreed;

  static const _passwordMinLength = 8;
  static const _passwordMaxLength = 20;
  static const _passwordNotes = [
    '半角英子文字大文字数字をそれぞれ1種類以上使用してください',
    '$_passwordMinLength文字以上$_passwordMaxLength文字以内で入力してください',
  ];
  static const _displayNameMaxLength = 20;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _displayNameController = TextEditingController();
    _recognizer = TapGestureRecognizer();
    _isAgreed = false;
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _recognizer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignUpScreenBloc>(
      create: (context) => SignUpScreenBloc(context: context),
      child: BlocBuilder<SignUpScreenBloc, SignUpScreenState>(
        builder: (context, state) {
          if (state is SignUpFailure) {
            if (state.type == SignUpFailureType.other) {
              return Scaffold(
                appBar: simpleAppBar(context, title: _appBarTitle),
                body: const Center(
                  child: BigTip(
                    title: Text('エラーが発生しました'),
                    child: Icon(Icons.error_outline_sharp),
                  ),
                ),
              );
            }
          }
          if (state is SignUpSuccess) {
            return Scaffold(
              appBar: simpleAppBar(context, title: _appBarTitle),
              body: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('アカウントを作成しました。'),
                      const SizedBox(height: 15),
                      const Text('以下のアドレスに確認メールを送信しました。'),
                      const SizedBox(height: 15),
                      Text(
                        state.email,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return _defaultView(context, state);
        },
      ),
    );
  }

  Widget _defaultView(BuildContext context, SignUpScreenState state) {
    void _signUpButtonEvent() {
      FocusScope.of(context).unfocus();
      if (_formKey.currentState.validate()) {
        if (!_isAgreed) {
          return showErrorModal(context, '利用規約に同意していません');
        }
        context.read<SignUpScreenBloc>().add(
              SignUpOnPressed(
                email: _emailController.text,
                password: _passwordController.text,
                displayName: _displayNameController.text,
              ),
            );
      }
    }

    return ModalProgressHUD(
      inAsyncCall: state is SignUpInProgress,
      child: Form(
        key: _formKey,
        child: Scaffold(
          appBar: simpleAppBar(context, title: 'アカウントを作成'),
          body: ScrollableLayoutBuilder(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          CustomTextFormField(
                            labelText: 'メールアドレス',
                            hintText: 'xxxxx@example.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            errorText: _emailErrorText(state),
                            validator: _emailValidator,
                          ),
                          const SizedBox(height: 30),
                          CustomTextFormField(
                            labelText: 'パスワード',
                            controller: _passwordController,
                            obscureText: true,
                            maxLength: _passwordMaxLength,
                            errorText: _passwordErrorText(state),
                            validator: _passwordValidator,
                          ),
                          const SizedBox(height: 30),
                          const BulletTexts(
                            texts: _passwordNotes,
                          ),
                          const SizedBox(height: 30),
                          CustomTextFormField(
                            labelText: 'パスワード(確認)',
                            controller: _confirmPasswordController,
                            obscureText: true,
                            maxLength: _passwordMaxLength,
                            validator: _confirmPasswordValidator,
                          ),
                          const SizedBox(height: 30),
                          CustomTextFormField(
                            labelText: 'ユーザー名',
                            controller: _displayNameController,
                            maxLength: _displayNameMaxLength,
                            validator: _displayNameValidator,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _termsOfServiceCell(),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: CustomRaisedButton(
                        labelText: 'アカウントを作成',
                        onPressed: _signUpButtonEvent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
                child: Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        text: '利用規約',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: _recognizer
                          ..onTap = () {
                            // TODO(Fukky21): 利用規約へ飛ぶ
                          },
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'に同意する',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(right: 5),
                child: CupertinoSwitch(
                  value: _isAgreed,
                  onChanged: (value) {
                    setState(() {
                      _isAgreed = value;
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

  String _emailErrorText(SignUpScreenState state) {
    if (state is SignUpFailure) {
      if (state.type == SignUpFailureType.emailAlreadyInUse) {
        return 'このアドレスは登録済です';
      }
      if (state.type == SignUpFailureType.invalidEmail) {
        return 'このアドレスは不正です';
      }
    }
    return null;
  }

  String _passwordErrorText(SignUpScreenState state) {
    if (state is SignUpFailure) {
      if (state.type == SignUpFailureType.weakPassword) {
        return 'パスワード強度が低いです';
      }
    }
    return null;
  }

  String _emailValidator(String email) {
    final errorMessages = <String>[]
      ..add(Validations.blank(email))
      ..add(Validations.emailFormat(email));
    for (final errorMessage in errorMessages) {
      if (errorMessage != null) {
        return errorMessage;
      }
    }
    return null;
  }

  String _passwordValidator(String password) {
    final errorMessages = <String>[]
      ..add(Validations.blank(password))
      ..add(Validations.rangeLength(
        password,
        _passwordMinLength,
        _passwordMaxLength,
      ))
      ..add(Validations.passwordFormat(password));
    for (final errorMessage in errorMessages) {
      if (errorMessage != null) {
        return errorMessage;
      }
    }
    return null;
  }

  String _confirmPasswordValidator(String confirmPassword) {
    final _password = _passwordController.text;
    final errorMessages = <String>[]
      ..add(Validations.blank(confirmPassword))
      ..add(Validations.confirmPassword(_password, confirmPassword));
    for (final errorMessage in errorMessages) {
      if (errorMessage != null) {
        return errorMessage;
      }
    }
    return null;
  }

  String _displayNameValidator(String displayName) {
    final errorMessages = <String>[]
      ..add(Validations.blank(displayName))
      ..add(Validations.maxLength(displayName, _displayNameMaxLength));
    for (final errorMessage in errorMessages) {
      if (errorMessage != null) {
        return errorMessage;
      }
    }
    return null;
  }
}
