import 'package:big_tip/big_tip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../blocs/global_blocs/authentication_bloc/index.dart';
import '../../blocs/global_blocs/cubits/index.dart';
import '../../blocs/screen_blocs/sign_in_screen_bloc/index.dart';
import '../../helpers/index.dart';
import '../../models/index.dart';
import '../../util/index.dart';
import '../../widgets/components/index.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  static const route = '/sign_in';

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController;
  TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignInScreenBloc>(
      create: (context) => SignInScreenBloc(),
      child: BlocBuilder<SignInScreenBloc, SignInScreenState>(
        builder: (context, state) {
          if (state is SignInFailure) {
            if (state.errorType == SignInFailure.errorTypeOther) {
              return _signInFailureView(context, state);
            }
          }
          if (state is SignInSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              BlocProvider.of<AuthenticationBloc>(context).add(SignedIn());
            });
            return _signInSuccessView(context, state);
          }
          return _defaultView(context, state);
        },
      ),
    );
  }

  Widget _signInFailureView(BuildContext context, SignInFailure state) {
    return Scaffold(
      appBar: transparentAppBar(context),
      body: const Center(
        child: BigTip(
          title: Text('エラーが発生しました'),
          child: Icon(Icons.error_outline_sharp),
        ),
      ),
    );
  }

  Widget _signInSuccessView(BuildContext context, SignInSuccess state) {
    return Scaffold(
      body: BlocBuilder<UserCubit, AppUser>(
        cubit: BlocProvider.of<UserCubit>(context),
        builder: (context, user) {
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomCircleAvatar(
                  filePath: user?.avatarIconFilePath,
                  radius: 50,
                ),
                const SizedBox(height: 10),
                Text(
                  user?.displayName ?? '',
                  style: Theme.of(context).textTheme.headline5,
                ),
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomRaisedButton(
                    labelText: 'ENTER',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _defaultView(BuildContext context, SignInScreenState state) {
    final _screenWidth = MediaQuery.of(context).size.width;

    String _emailErrorText;
    String _passwordErrorText;
    if (state is SignInFailure) {
      if (state.errorType == SignInFailure.errorTypeInvalidEmail) {
        _emailErrorText = 'このアドレスは不正です';
      }
      if (state.errorType == SignInFailure.errorTypeUserNotFound) {
        _emailErrorText = 'このアドレスは登録されていません';
      }
      if (state.errorType == SignInFailure.errorTypeWrongPassword) {
        _passwordErrorText = 'パスワードが間違っています';
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
      return null;
    }

    void _signInButtonEvent() {
      FocusScope.of(context).unfocus();
      if (_formKey.currentState.validate()) {
        BlocProvider.of<SignInScreenBloc>(context).add(
          SignInWithEmailAndPasswordOnPressed(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );
      }
    }

    return ModalProgressHUD(
      inAsyncCall: state is SignInInProgress,
      child: Form(
        key: _formKey,
        child: Scaffold(
          appBar: transparentAppBar(context),
          body: ScrollableLayoutBuilder(
            body: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 50,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppIcons.karitomorise,
                      width: _screenWidth * 0.4,
                    ),
                    const SizedBox(height: 30),
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
                      errorText: _passwordErrorText,
                      validator: _passwordValidator,
                    ),
                    const SizedBox(height: 30),
                    CustomRaisedButton(
                      labelText: 'サインイン',
                      onPressed: _signInButtonEvent,
                    ),
                    const SizedBox(height: 30),
                    CustomDivider(),
                    const SizedBox(height: 30),
                    const Text('持っているアカウントでサインイン'),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleIconButton(
                          iconType: CircleIconButton.iconTypeGoogle,
                          onTap: () {
                            // TODO(Fukky21): Googleログインを実装する
                          },
                        ),
                        const SizedBox(width: 30),
                        CircleIconButton(
                          iconType: CircleIconButton.iconTypeFacebook,
                          onTap: () {
                            // TODO(Fukky21): Facebookログインを実装する
                          },
                        ),
                        const SizedBox(width: 30),
                        CircleIconButton(
                          iconType: CircleIconButton.iconTypeTwitter,
                          onTap: () {
                            // TODO(Fukky21): Twitterログインを実装する
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    CustomDivider(),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomOutlineButton(
                          width: _screenWidth * 0.45,
                          labelText: 'パスワードを\nお忘れの方',
                          maxLines: 2,
                          onPressed: () {
                            // TODO(Fukky21): パスワードをお忘れの方画面を実装
                          },
                        ),
                        CustomOutlineButton(
                          width: _screenWidth * 0.45,
                          labelText: 'アカウントを作成',
                          onPressed: () {
                            Navigator.pushNamed(context, SignUpScreen.route);
                          },
                        ),
                      ],
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
