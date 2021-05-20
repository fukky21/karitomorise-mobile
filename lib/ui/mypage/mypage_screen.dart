import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../repositories/firebase_post_repository.dart';
import '../../stores/authentication_store.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_circle_avatar.dart';
import '../../ui/components/custom_divider.dart';
import '../../ui/components/custom_modal.dart';
import '../../ui/components/custom_raised_button.dart';
import '../../ui/edit_user/edit_user_screen.dart';
import '../../ui/sign_in/sign_in_screen.dart';
import '../../util/app_colors.dart';

class MypageScreen extends StatelessWidget {
  static const route = '/mypage';
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
            _createDummyPostsButton(context),
          ],
        ),
      ),
    );
  }

  // TODO(fukky21): 後で削除する
  Widget _createDummyPostsButton(BuildContext context) {
    final postRepository = FirebasePostRepository();

    return CustomRaisedButton(
      width: 300,
      labelText: 'ダミーの投稿を作成',
      onPressed: () async {
        if (await showConfirmModal(context, 'ダミー投稿を作成しますか？')) {
          await postRepository.createDummyPosts();
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

    final authState = context.watch<AuthenticationStore>().getState();

    if (authState is AuthenticationSuccess) {
      if (!authState.currentUser.isAnonymous) {
        final user = authState.user;

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
                EditUserScreen.route,
                arguments: EditUserScreenArguments(
                  name: user.name,
                  avatar: user.avatar,
                ),
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
                            filePath: user.avatar?.filePath,
                            radius: _height / 2 - 10,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              user.name ?? 'Unknown',
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
    }

    return Container();
  }
}

class _SignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthenticationStore>().getState();

    if (authState is AuthenticationSuccess) {
      final isAnonymous = authState.currentUser.isAnonymous;

      return Column(
        children: [
          CustomDivider(),
          Material(
            color: AppColors.grey20,
            child: InkWell(
              onTap: () async {
                if (!isAnonymous) {
                  if (await showConfirmModal(context, 'サインアウトしますか？')) {
                    await context.read<AuthenticationStore>().signedOut();
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
                  isAnonymous ? 'サインインする' : 'サインアウトする',
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
  }
}
