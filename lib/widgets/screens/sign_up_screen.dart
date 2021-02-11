import 'package:big_tip/big_tip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../blocs/screen_blocs/sign_up_screen_bloc/index.dart';
import '../../helpers/index.dart';
import '../../util/index.dart';
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
  TapGestureRecognizer _recognizer;
  bool _isAgreed;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
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
      create: (context) => SignUpScreenBloc(),
      child: BlocBuilder<SignUpScreenBloc, SignUpScreenState>(
        builder: (context, state) {
          if (state is SignUpFailure) {
            if (state.errorType == SignUpFailure.errorTypeOther) {
              return _signUpFailureView(context, state);
            }
          }
          if (state is SignUpSuccess) {
            return _signUpSuccessView(context, state);
          }
          return _defaultView(context, state);
        },
      ),
    );
  }

  Widget _signUpFailureView(BuildContext context, SignUpFailure state) {
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

  Widget _signUpSuccessView(BuildContext context, SignUpSuccess state) {
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

  Widget _defaultView(BuildContext context, SignUpScreenState state) {
    const _passwordMinLength = 8;
    const _passwordMaxLength = 20;

    const _passwordNotes = [
      '半角英子文字大文字数字をそれぞれ1種類以上使用してください',
      '$_passwordMinLength文字以上$_passwordMaxLength文字以内で入力してください',
    ];

    String _emailErrorText;
    String _passwordErrorText;
    if (state is SignUpFailure) {
      if (state.errorType == SignUpFailure.errorTypeEmailAlreadyInUse) {
        _emailErrorText = 'このアドレスは登録済です';
      }
      if (state.errorType == SignUpFailure.errorTypeInvalidEmail) {
        _emailErrorText = 'このアドレスは不正です';
      }
      if (state.errorType == SignUpFailure.errorTypeWeakPassword) {
        _passwordErrorText = 'パスワード強度が低いです';
      }
    }

    String _emailValidator(String email) {
      final blankErrorText = blankValidator(email);
      if (blankErrorText != null) {
        return blankErrorText;
      }
      final emailFormatErrorText = emailFormatValidator(email);
      if (emailFormatErrorText != null) {
        return emailFormatErrorText;
      }
      return null;
    }

    String _passwordValidator(String password) {
      final blankErrorText = blankValidator(password);
      if (blankErrorText != null) {
        return blankErrorText;
      }
      final rangeLengthErrorText = rangeLengthValidator(
        password,
        _passwordMinLength,
        _passwordMaxLength,
      );
      if (rangeLengthErrorText != null) {
        return rangeLengthErrorText;
      }
      final passwordFormatErrorText = passwordFormatValidator(password);
      if (passwordFormatErrorText != null) {
        return passwordFormatErrorText;
      }
      return null;
    }

    String _confirmPasswordValidator(String confirmPassword) {
      final blankErrorText = blankValidator(confirmPassword);
      if (blankErrorText != null) {
        return blankErrorText;
      }
      final password = _passwordController.text;
      final confirmPasswordErrorText = confirmPasswordValidator(
        password,
        confirmPassword,
      );
      if (confirmPasswordErrorText != null) {
        return confirmPasswordErrorText;
      }
      return null;
    }

    void _signUpButtonEvent() {
      FocusScope.of(context).unfocus();
      if (_formKey.currentState.validate()) {
        if (!_isAgreed) {
          return showErrorModal(context, '利用規約に同意していません');
        }
        BlocProvider.of<SignUpScreenBloc>(context).add(
          SignUpOnPressed(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );
      }
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

    return ModalProgressHUD(
      inAsyncCall: state is SignUpInProgress,
      child: Form(
        key: _formKey,
        child: Scaffold(
          appBar: simpleAppBar(context, title: 'アカウントを作成'),
          body: ScrollableLayoutBuilder(
            body: Center(
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
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            errorText: _emailErrorText,
                            validator: _emailValidator,
                          ),
                          const SizedBox(height: 30),
                          CustomTextFormField(
                            labelText: 'パスワード',
                            controller: _passwordController,
                            obscureText: true,
                            maxLength: _passwordMaxLength,
                            errorText: _passwordErrorText,
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
}
