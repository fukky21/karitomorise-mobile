import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../blocs/authentication_bloc/index.dart';
import '../../models/index.dart';
import '../../providers/index.dart';
import '../../utils/index.dart';
import '../../widgets/components/index.dart';
import '../../widgets/screens/index.dart';

class MyPageTab extends StatelessWidget {
  static const _appBarTitle = 'マイページ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(context, title: _appBarTitle),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _accountCard(context),
            const SizedBox(height: 20),
            _signButton(context),
            const SizedBox(height: 20),
            CustomRaisedButton(
              width: 300,
              labelText: 'GO TO TEST USER2',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  ShowUserScreen.route,
                  arguments: ShowUserScreenArguments(
                    uid: 'PuxczFjpfjUdbD2kkspZSkW3YKl1',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _accountCard(BuildContext context) {
    final _width = MediaQuery.of(context).size.width * 0.9;
    const _height = 80.0;

    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      cubit: context.watch<AuthenticationBloc>(),
      builder: (context, state) {
        if (state is AuthenticationSuccess) {
          return Consumer<UsersProvider>(
            builder: (context, provider, _) {
              final _user = provider.get(uid: state.currentUser.uid);
              Widget _child;
              void Function() _onTap;
              if (_user == null) {
                _child = const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                _child = Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Flexible(
                        child: Row(
                          children: [
                            CustomCircleAvatar(
                              filePath: _user.avatar?.iconFilePath,
                              radius: _height / 2 - 10,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                _user.displayName ?? 'Unknown',
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
                );
                _onTap = () {
                  Navigator.pushNamed(
                    context,
                    ShowUserScreen.route,
                    arguments: ShowUserScreenArguments(uid: _user.id),
                  );
                };
              }

              return Card(
                color: AppColors.grey20,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    width: _width,
                    height: _height,
                    child: _child,
                  ),
                  onTap: _onTap,
                ),
              );
            },
          );
        }
        return Container();
      },
    );
  }

  Widget _signButton(BuildContext context) {
    return Column(
      children: [
        CustomDivider(),
        Material(
          color: AppColors.grey20,
          child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            cubit: context.watch<AuthenticationBloc>(),
            builder: (context, state) {
              return InkWell(
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 50,
                  child: Text(
                    state is AuthenticationSuccess ? 'サインアウト' : 'サインイン',
                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                          color: state is AuthenticationSuccess
                              ? Theme.of(context).errorColor
                              : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                onTap: () async {
                  if (state is AuthenticationSuccess) {
                    if (await showConfirmModal(context, 'サインアウトしますか？')) {
                      context.read<AuthenticationBloc>().add(SignedOut());
                    }
                  } else {
                    Navigator.pushNamed(context, SignInScreen.route);
                  }
                },
              );
            },
          ),
        ),
        CustomDivider(),
      ],
    );
  }
}
