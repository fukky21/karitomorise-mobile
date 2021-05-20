import 'package:big_tip/big_tip.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../stores/authentication_store.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_circle_avatar.dart';
import '../../ui/components/custom_divider.dart';
import '../../ui/components/custom_outline_button.dart';
import '../../ui/components/custom_raised_button.dart';
import '../../ui/components/custom_text_form_field.dart';
import '../../ui/components/scrollable_layout_builder.dart';
import '../../ui/sign_up/sign_up_screen.dart';
import '../../util/validations.dart';
import 'sign_in_view_model.dart';

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
    return ChangeNotifierProvider(
      create: (context) => SignInViewModel(
        authStore: context.read<AuthenticationStore>(),
      ),
      child: Consumer<SignInViewModel>(
        builder: (context, viewModel, _) {
          final state = viewModel.getState();
          final screenWidth = MediaQuery.of(context).size.width;

          Future<void> _signInButtonEvent() async {
            FocusScope.of(context).unfocus();
            if (_formKey.currentState.validate()) {
              await viewModel.signInWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text,
              );
            }
          }

          if (state is SignInFailure && state.type == SignInFailureType.other) {
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

          if (state is SignInSuccess) {
            final authState = context.watch<AuthenticationStore>().getState();

            if (authState is AuthenticationSuccess) {
              final user = authState.user;

              return Scaffold(
                body: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomCircleAvatar(
                          filePath: user.avatar.filePath,
                          radius: 50,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          user.name ?? 'Unknown',
                          style: Theme.of(context).textTheme.headline5,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 50),
                        CustomRaisedButton(
                          labelText: 'ENTER',
                          onPressed: () async => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
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
                            'assets/karitomorise_logo.png',
                            width: screenWidth * 0.4,
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
                                width: screenWidth * 0.45,
                                labelText: 'パスワードを\nお忘れの方',
                                maxLines: 2,
                                onPressed: () {
                                  // TODO(Fukky21): パスワードをお忘れの方画面を実装
                                },
                              ),
                              CustomOutlineButton(
                                width: screenWidth * 0.45,
                                labelText: 'アカウントを作成',
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    SignUpScreen.route,
                                  );
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
        },
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
    final errorMessages = <String>[
      Validations.blank(text: password),
      Validations.passwordFormat(password: password),
    ];
    for (final errorMessage in errorMessages) {
      if (errorMessage != null) {
        return errorMessage;
      }
    }
    return null;
  }
}
