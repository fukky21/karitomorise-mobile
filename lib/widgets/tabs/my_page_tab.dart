import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../blocs/global_blocs/authentication_bloc/index.dart';
import '../../blocs/global_blocs/current_user_bloc/index.dart';
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
                  _accountCard(context, authState),
                  const SizedBox(height: 20),
                  CustomDivider(),
                  _signInButton(context, authState),
                  CustomDivider(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _accountCard(BuildContext context, AuthenticationState authState) {
    final _width = MediaQuery.of(context).size.width;

    if (authState is AuthenticationSuccess) {
      return BlocBuilder<CurrentUserBloc, CurrentUserState>(
        builder: (context, state) {
          return Card(
            color: AppColors.grey20,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                if (state?.user != null) {
                  Navigator.pushNamed(
                    context,
                    ShowUserScreen.route,
                    arguments: ShowUserScreenArguments(uid: state.user.id),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                width: _width * 0.9,
                child: state?.user == null
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Flexible(
                              child: Row(
                                children: [
                                  CustomCircleAvatar(
                                    filePath: state.user?.avatarIconFilePath,
                                    radius: _width * 0.0855,
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      state.user?.displayName ?? '',
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

  Widget _signInButton(BuildContext context, AuthenticationState authState) {
    return Material(
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
    );
  }
}
