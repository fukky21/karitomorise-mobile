import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../models/index.dart';
import '../../notifiers/index.dart';
import '../../repositories/index.dart';
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
            _AccountCard(),
            const SizedBox(height: 20),
            _SignInButton(),
            const SizedBox(height: 20),
            _goToUser2Button(context),
            const SizedBox(height: 20),
            _createDummyEventsButton(context),
          ],
        ),
      ),
    );
  }

  // TODO(Fukky21): 後で削除する(_goToUser2Button)
  Widget _goToUser2Button(BuildContext context) {
    return CustomRaisedButton(
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
    );
  }

  // TODO(Fukky21): 後で削除する(_createDummyEventsButton)
  Widget _createDummyEventsButton(BuildContext context) {
    return CustomRaisedButton(
      width: 300,
      labelText: 'ダミー募集を作成',
      onPressed: () async {
        if (await showConfirmModal(context, 'ダミーイベントを作成しますか？')) {
          await context
              .read<FirebaseEventRepository>()
              .createDummyEvents(context);
        }
      },
    );
  }
}

class _AccountCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width * 0.9;
    const _height = 80.0;

    return Consumer<AuthenticationNotifier>(
      builder: (context, notifier, _) {
        final state = notifier?.state ?? AuthenticationInProgress();

        if (state is AuthenticationSuccess &&
            state.currentUser != null &&
            !state.currentUser.isAnonymous) {
          final user = state.user;

          return Card(
            color: AppColors.grey20,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  ShowUserScreen.route,
                  arguments: ShowUserScreenArguments(uid: user.id),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                width: _width,
                height: _height,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Flexible(
                        child: Row(
                          children: [
                            CustomCircleAvatar(
                              filePath: user.avatar?.iconFilePath,
                              radius: _height / 2 - 10,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                user.displayName ?? 'Unknown',
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
        }

        return Container();
      },
    );
  }
}

class _SignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationNotifier>(
      builder: (context, notifier, _) {
        final state = notifier?.state ?? AuthenticationInProgress();

        if (state is AuthenticationSuccess && state.currentUser != null) {
          final isAnonymous = state.currentUser.isAnonymous;

          return Column(
            children: [
              CustomDivider(),
              Material(
                color: AppColors.grey20,
                child: InkWell(
                  onTap: () async {
                    if (state is AuthenticationSuccess) {
                      if (await showConfirmModal(context, 'サインアウトしますか？')) {
                        await notifier.signOut();
                      }
                    } else {
                      await Navigator.pushNamed(context, SignInScreen.route);
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 50,
                    child: Text(
                      isAnonymous ? 'サインイン' : 'サインアウト',
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            color: isAnonymous
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ),
              CustomDivider(),
            ],
          );
        }

        return Container();
      },
    );
  }
}
