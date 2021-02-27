import 'package:big_tip/big_tip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import '../../blocs/sign_in_screen_bloc/index.dart';
import '../../models/index.dart';
import '../../providers/index.dart';
import '../../utils/index.dart';
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
      create: (context) => SignInScreenBloc(context: context),
      child: BlocBuilder<SignInScreenBloc, SignInScreenState>(
        builder: (context, state) {
          if (state is SignInFailure) {
            if (state.type == SignInFailureType.other) {
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
          }
          if (state is SignInSuccess) {
            return _signInSuccessView(context);
          }
          return _defaultView(context, state);
        },
      ),
    );
  }

  Widget _signInSuccessView(BuildContext context) {
    final _currentUser = context.watch<CurrentUserProvider>().currentUser;
    AppUser _user;
    if (_currentUser != null) {
      _user = context.watch<UsersProvider>().get(_currentUser.uid);
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Consumer<CurrentUserProvider>(
      builder: (context, currentUserProvider, _) {
        return Consumer<UsersProvider>(
          builder: (context, usersProvider, _) {
            final _currentUser = currentUserProvider.currentUser;
            if (_currentUser != null) {
              final _user = usersProvider.get(_currentUser.uid);
              if (_user != null) {
                return Scaffold(
                  body: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomCircleAvatar(
                            filePath: _user.avatarType?.iconFilePath,
                            radius: 50,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _user.displayName ?? 'Unknown',
                            style: Theme.of(context).textTheme.headline5,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 50),
                          CustomRaisedButton(
                            labelText: 'ENTER',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            }
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _defaultView(BuildContext context, SignInScreenState state) {
    final _screenWidth = MediaQuery.of(context).size.width;

    void _signInButtonEvent() {
      FocusScope.of(context).unfocus();
      if (_formKey.currentState.validate()) {
        BlocProvider.of<SignInScreenBloc>(context).add(
          SignInOnPressed(
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
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 50,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/karitomorise_icon.png',
                      width: _screenWidth * 0.4,
                    ),
                    const SizedBox(height: 30),
                    CustomTextFormField(
                      labelText: 'メールアドレス',
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
                      errorText: _passwordErrorText(state),
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

  String _emailErrorText(SignInScreenState state) {
    if (state is SignInFailure) {
      if (state.type == SignInFailureType.invalidEmail) {
        return 'このアドレスは不正です';
      }
      if (state.type == SignInFailureType.userNotFound) {
        return 'このアドレスは登録されていません';
      }
    }
    return null;
  }

  String _passwordErrorText(SignInScreenState state) {
    if (state is SignInFailure) {
      if (state.type == SignInFailureType.wrongPassword) {
        return 'パスワードが間違っています';
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
      ..add(Validations.passwordFormat(password));
    for (final errorMessage in errorMessages) {
      if (errorMessage != null) {
        return errorMessage;
      }
    }
    return null;
  }
}
