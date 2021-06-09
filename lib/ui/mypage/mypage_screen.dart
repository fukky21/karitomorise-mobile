import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/app_user.dart';
import '../../repositories/shared_preference_repository.dart';
import '../../store.dart';
import '../../ui/basic_usage/basic_usage_screen.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_circle_avatar.dart';
import '../../ui/components/custom_divider.dart';
import '../../ui/components/custom_modal.dart';
import '../../ui/components/custom_snack_bar.dart';
import '../../ui/components/scrollable_layout_builder.dart';
import '../../ui/delete_user/delete_user_screen.dart';
import '../../ui/edit_email/edit_email_screen.dart';
import '../../ui/edit_password/edit_password_screen.dart';
import '../../ui/edit_user/edit_user_screen.dart';
import '../../ui/mypage/mypage_view_model.dart';
import '../../ui/show_license/show_license_screen.dart';
import '../../ui/sign_in/sign_in_screen.dart';
import '../../util/app_colors.dart';

class MypageScreen extends StatelessWidget {
  static const route = '/mypage';
  static const _appBarTitle = 'マイページ';

  @override
  Widget build(BuildContext context) {
    final currentUser = context.select((Store store) => store.currentUser);
    final user = context.select((Store store) => store.users[currentUser?.uid]);

    return ChangeNotifierProvider(
      create: (_) => MypageViewModel(),
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
                      _AccountCard(
                        isAnonymous: currentUser?.isAnonymous ?? true,
                        user: user,
                      ),
                      const SizedBox(height: 40),
                      CustomDivider(),
                      _EditEmailCell(
                          isAnonymous: currentUser?.isAnonymous ?? true),
                      CustomDivider(),
                      _EditPasswordCell(
                          isAnonymous: currentUser?.isAnonymous ?? true),
                      CustomDivider(),
                      _DeleteSearchHistoriesCell(),
                      CustomDivider(),
                      _ClearBlockListCell(),
                      CustomDivider(),
                      _ShowBasicUsageCell(),
                      CustomDivider(),
                      _ShowTermsOfServiceCell(),
                      CustomDivider(),
                      _ShowPrivacyPolicyCell(),
                      CustomDivider(),
                      _ShowLicenceCell(),
                      CustomDivider(),
                      _ShowContactCell(),
                      CustomDivider(),
                      _DeleteAccountCell(
                          isAnonymous: currentUser?.isAnonymous ?? true),
                      CustomDivider(),
                      const SizedBox(height: 40),
                      _SignInButton(
                        isAnonymous: currentUser?.isAnonymous ?? true,
                        signOutEvent: () async => viewModel.signOut(),
                      ),
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
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({@required this.isAnonymous, @required this.user});

  final bool isAnonymous;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width * 0.9;
    const _height = 80.0;

    return Card(
      color: AppColors.grey20,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: !isAnonymous
            ? () {
                Navigator.pushNamed(
                  context,
                  EditUserScreen.route,
                  arguments: EditUserScreenArguments(
                    name: user?.name,
                    avatar: user?.avatar,
                  ),
                );
              }
            : null,
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
                        filePath: user?.avatar?.filePath,
                        radius: _height / 2 - 10,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          user?.name ?? 'Unknown',
                          maxLines: 2,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 5),
                child: !isAnonymous
                    ? const Icon(Icons.chevron_right_sharp)
                    : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditEmailCell extends StatelessWidget {
  const _EditEmailCell({@required this.isAnonymous});

  final bool isAnonymous;

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
          if (isAnonymous) {
            Navigator.pushNamed(context, SignInScreen.route);
          } else {
            Navigator.pushNamed(context, EditEmailScreen.route);
          }
        },
      ),
    );
  }
}

class _EditPasswordCell extends StatelessWidget {
  const _EditPasswordCell({@required this.isAnonymous});

  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: const BoxDecoration(
        color: AppColors.grey20,
      ),
      child: ListTile(
        title: const Text('パスワードの変更'),
        trailing: const Icon(Icons.chevron_right_sharp),
        onTap: () {
          if (isAnonymous) {
            Navigator.pushNamed(context, SignInScreen.route);
          } else {
            Navigator.pushNamed(context, EditPasswordScreen.route);
          }
        },
      ),
    );
  }
}

class _DeleteSearchHistoriesCell extends StatelessWidget {
  final _prefRepository = SharedPreferenceRepository();

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: const BoxDecoration(
        color: AppColors.grey20,
      ),
      child: ListTile(
        title: const Text('検索履歴の全削除'),
        trailing: const Icon(Icons.chevron_right_sharp),
        onTap: () async {
          if (await showConfirmModal(context, '検索履歴を全て削除しますか？')) {
            try {
              await _prefRepository.clearSearchHistory();
              showSnackBar(context, '検索履歴を全て削除しました');
            } on Exception catch (e) {
              debugPrint(e.toString());
            }
          }
        },
      ),
    );
  }
}

class _ClearBlockListCell extends StatelessWidget {
  final _prefRepository = SharedPreferenceRepository();

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: const BoxDecoration(
        color: AppColors.grey20,
      ),
      child: ListTile(
        title: const Text('ブロックリストの初期化'),
        trailing: const Icon(Icons.chevron_right_sharp),
        onTap: () async {
          if (await showConfirmModal(context, 'ブロックリストを初期化しますか？')) {
            try {
              await _prefRepository.clearBlockList();
              context.read<Store>().setBlockList([]);
              showSnackBar(context, 'ブロックリストを初期化しました');
            } on Exception catch (e) {
              debugPrint(e.toString());
            }
          }
        },
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
        onTap: () {
          Navigator.pushNamed(context, BasicUsageScreen.route);
        },
      ),
    );
  }
}

class _ShowTermsOfServiceCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: const BoxDecoration(
        color: AppColors.grey20,
      ),
      child: ListTile(
        title: const Text('利用規約'),
        trailing: const Icon(Icons.chevron_right_sharp),
        onTap: () async {
          final baseURL = dotenv.env['HP_BASE_URL'];
          final url = '$baseURL/terms_of_service';
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            showErrorModal(context, 'エラーが発生しました');
          }
        },
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
        onTap: () async {
          final baseURL = dotenv.env['HP_BASE_URL'];
          final url = '$baseURL/privacy_policy';
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            showErrorModal(context, 'エラーが発生しました');
          }
        },
      ),
    );
  }
}

class _ShowLicenceCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: const BoxDecoration(
        color: AppColors.grey20,
      ),
      child: ListTile(
        title: const Text('ライセンス'),
        trailing: const Icon(Icons.chevron_right_sharp),
        onTap: () {
          Navigator.pushNamed(context, ShowLicenseScreen.route);
        },
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
        onTap: () async {
          const url =
              'https://docs.google.com/forms/d/e/1FAIpQLSfVpwYT13Sr-Xrj-Ywe3gdVDBuJPDgvqE6ijHde_g3TcfTKUQ/viewform?usp=sf_link';
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            showErrorModal(context, 'エラーが発生しました');
          }
        },
      ),
    );
  }
}

class _DeleteAccountCell extends StatelessWidget {
  const _DeleteAccountCell({@required this.isAnonymous});

  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: const BoxDecoration(
        color: AppColors.grey20,
      ),
      child: ListTile(
        title: const Text('アカウントを削除する'),
        trailing: const Icon(Icons.chevron_right_sharp),
        onTap: () {
          if (isAnonymous) {
            Navigator.pushNamed(context, SignInScreen.route);
          } else {
            Navigator.pushNamed(context, DeleteUserScreen.route);
          }
        },
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton({
    @required this.isAnonymous,
    @required this.signOutEvent,
  });

  final bool isAnonymous;
  final Future<void> Function() signOutEvent;

  @override
  Widget build(BuildContext context) {
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
