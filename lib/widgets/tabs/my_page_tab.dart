import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../blocs/global_blocs/authentication_bloc/index.dart';
import '../../blocs/global_blocs/cubits/index.dart';
import '../../models/index.dart';
import '../../util/index.dart';
import '../../widgets/components/index.dart';
import '../../widgets/screens/index.dart';

class MyPageTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, authState) {
        return ModalProgressHUD(
          inAsyncCall: authState is AuthenticationInProgress,
          child: Scaffold(
            appBar: simpleAppBar(context, title: 'マイページ'),
            body: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AccountCard(authState: authState),
                  const SizedBox(height: 20),
                  _SignInButton(authState: authState),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({@required this.authState});

  final AuthenticationState authState;

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    if (authState is AuthenticationSuccess) {
      return BlocBuilder<UserCubit, AppUser>(
        builder: (context, user) {
          return Card(
            color: AppColors.grey20,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                // TODO(Fukky21): ユーザー詳細画面へ遷移する
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                width: _width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Flexible(
                        child: Row(
                          children: [
                            CustomCircleAvatar(
                              avatarType: user?.avatarType,
                              radius: _width * 0.0855,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                user?.displayName ?? '',
                                maxLines: 2,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 5),
                      child: const Icon(Icons.chevron_right_sharp),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
    return Container();
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton({@required this.authState});

  final AuthenticationState authState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomDivider(),
        Material(
          color: AppColors.grey20,
          child: InkWell(
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: 50,
              child: Text(
                authState is AuthenticationSuccess ? 'サインアウト' : 'サインイン',
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: authState is AuthenticationSuccess
                          ? Theme.of(context).errorColor
                          : Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            onTap: () {
              if (authState is AuthenticationSuccess) {
                BlocProvider.of<AuthenticationBloc>(context).add(SignedOut());
              } else {
                Navigator.pushNamed(context, SignInScreen.route);
              }
            },
          ),
        ),
        CustomDivider(),
      ],
    );
  }
}
