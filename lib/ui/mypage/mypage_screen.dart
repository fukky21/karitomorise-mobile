import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../repositories/firebase_post_repository.dart';
import '../../stores/signed_in_user_store.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_circle_avatar.dart';
import '../../ui/components/custom_divider.dart';
import '../../ui/components/custom_modal.dart';
import '../../ui/components/custom_raised_button.dart';
import '../../ui/components/scrollable_layout_builder.dart';
import '../../ui/edit_email/edit_email_screen.dart';
import '../../ui/edit_user/edit_user_screen.dart';
import '../../ui/mypage/mypage_view_model.dart';
import '../../ui/sign_in/sign_in_screen.dart';
import '../../util/app_colors.dart';

class MypageScreen extends StatelessWidget {
  static const route = '/mypage';
  static const _appBarTitle = 'マイページ';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MypageViewModel(
        signedInUserStore: context.read<SignedInUserStore>(),
      ),
      child: Consumer<MypageViewModel>(
        builder: (context, viewModel, _) {
          final state = viewModel.getState();

          return ModalProgressHUD(
            inAsyncCall: state?.loading ?? false,
            child: Scaffold(
              appBar: simpleAppBar(context, title: _appBarTitle),
              body: ScrollableLayoutBuilder(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _AccountCard(),
                      const SizedBox(height: 40),
                      CustomDivider(),
                      _EditEmailCell(),
                      CustomDivider(),
                      _EditPasswordCell(),
                      CustomDivider(),
                      _DeleteSearchHistoriesCell(),
                      CustomDivider(),
                      _ShowBasicUsageCell(),
                      CustomDivider(),
                      _ShowPrivacyPolicyCell(),
                      CustomDivider(),
                      _ShowContactCell(),
                      CustomDivider(),
                      _DeleteAccountCell(),
                      CustomDivider(),
                      const SizedBox(height: 40),
                      _SignInButton(
                        signOutEvent: () async => viewModel.signOut(),
                      ),
                      const SizedBox(height: 20),
                      _createDummyPostsButton(context),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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

    final signedInUser = context.watch<SignedInUserStore>().getUser();

    if (signedInUser.id != null) {
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
                name: signedInUser.name,
                avatar: signedInUser.avatar,
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
                          filePath: signedInUser.avatar?.filePath,
                          radius: _height / 2 - 10,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            signedInUser.name ?? 'Unknown',
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
  }
}

class _EditEmailCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: const BoxDecoration(
        color: AppColors.grey20,
      ),
      child: ListTile(
        title: const Text('メールアドレスの変更'),
        trailing: const Icon(Icons.chevron_right_sharp),
        onTap: () {
          Navigator.pushNamed(context, EditEmailScreen.route);
        },
      ),
    );
  }
}

class _EditPasswordCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: const BoxDecoration(
        color: AppColors.grey20,
      ),
      child: ListTile(
        title: const Text('パスワードの変更'),
        trailing: const Icon(Icons.chevron_right_sharp),
        onTap: () async {},
      ),
    );
  }
}

class _DeleteSearchHistoriesCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: const BoxDecoration(
        color: AppColors.grey20,
      ),
      child: ListTile(
        title: const Text('検索履歴の全削除'),
        trailing: const Icon(Icons.chevron_right_sharp),
        onTap: () async {},
      ),
    );
  }
}

class _ShowBasicUsageCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: const BoxDecoration(
        color: AppColors.grey20,
      ),
      child: ListTile(
        title: const Text('基本的な使い方'),
        trailing: const Icon(Icons.chevron_right_sharp),
        onTap: () async {},
      ),
    );
  }
}

class _ShowPrivacyPolicyCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: const BoxDecoration(
        color: AppColors.grey20,
      ),
      child: ListTile(
        title: const Text('プライバシーポリシー'),
        trailing: const Icon(Icons.chevron_right_sharp),
        onTap: () async {},
      ),
    );
  }
}

class _ShowContactCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: const BoxDecoration(
        color: AppColors.grey20,
      ),
      child: ListTile(
        title: const Text('お問い合わせ'),
        trailing: const Icon(Icons.chevron_right_sharp),
        onTap: () async {},
      ),
    );
  }
}

class _DeleteAccountCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: const BoxDecoration(
        color: AppColors.grey20,
      ),
      child: ListTile(
        title: const Text('アカウントを削除する'),
        trailing: const Icon(Icons.chevron_right_sharp),
        onTap: () async {},
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton({@required this.signOutEvent});

  final Future<void> Function() signOutEvent;

  @override
  Widget build(BuildContext context) {
    final signedInUser = context.watch<SignedInUserStore>().getUser();
    final isAnonymous = signedInUser.id == null;

    return Column(
      children: [
        CustomDivider(),
        Material(
          color: AppColors.grey20,
          child: InkWell(
            onTap: () async {
              if (!isAnonymous) {
                if (await showConfirmModal(context, 'サインアウトしますか？')) {
                  await signOutEvent();
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
}
