import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../stores/signed_in_user_store.dart';
import '../../ui/components/bullet_texts.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_circle_avatar.dart';
import '../../ui/components/custom_raised_button.dart';
import '../../ui/components/custom_text_form_field.dart';
import '../../ui/components/scrollable_layout_builder.dart';
import '../../util/validations.dart';
import 'delete_user_view_model.dart';

class DeleteUserScreen extends StatefulWidget {
  static const route = '/delete_user';

  @override
  _DeleteUserScreenState createState() => _DeleteUserScreenState();
}

class _DeleteUserScreenState extends State<DeleteUserScreen> {
  final _appBarTitle = 'アカウントを削除';
  final _formKey = GlobalKey<FormState>();
  TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DeleteUserViewModel(
        signedInUserStore: context.read<SignedInUserStore>(),
      ),
      child: Consumer<DeleteUserViewModel>(
        builder: (context, viewModel, _) {
          final state = viewModel.getState();

          if (state is DeleteUserInProgress) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('アカウントを削除しています'),
                      SizedBox(height: 40),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state is DeleteUserFailure &&
              state.type == DeleteUserFailureType.other) {
            return Scaffold(
              appBar: simpleAppBar(context, title: _appBarTitle),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('エラーが発生しました'),
                      const SizedBox(height: 40),
                      CustomRaisedButton(
                        labelText: 'とじる',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state is DeleteUserSuccess) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('アカウントの削除が完了しました'),
                      const SizedBox(height: 40),
                      CustomRaisedButton(
                        labelText: 'とじる',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            appBar: simpleAppBar(context, title: _appBarTitle),
            body: Form(
              key: _formKey,
              child: ScrollableLayoutBuilder(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 30,
                  ),
                  child: Column(
                    children: [
                      _notes(context),
                      const SizedBox(height: 15),
                      _userAvatarAndName(context),
                      const SizedBox(height: 15),
                      CustomTextFormField(
                        labelText: 'パスワード',
                        controller: _passwordController,
                        obscureText: true,
                        errorText: _passwordErrorText(state),
                        validator: (password) {
                          return Validations.blank(text: password);
                        },
                      ),
                      const SizedBox(height: 45),
                      CustomRaisedButton(
                        labelText: '削除する',
                        isDanger: true,
                        onPressed: () async {
                          await deleteButtonEvent(context, viewModel);
                        },
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

  Widget _notes(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).errorColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: const [
          Text(
            '注意事項',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          BulletTexts(
            texts: [
              'メールアドレスを含む全てのユーザー情報が削除されます',
              '過去の投稿を削除することはできません',
              'サインインができなくなるため、通知機能が使用できなくなります',
              '通知機能を使用する場合は再度アカウントを作成し直す必要があります',
            ],
          ),
        ],
      ),
    );
  }

  Widget _userAvatarAndName(BuildContext context) {
    final signedInUser = context.read<SignedInUserStore>().getUser();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomCircleAvatar(
          filePath: signedInUser?.avatar?.filePath ?? '',
          radius: 30,
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            signedInUser?.name ?? 'Unknown',
            maxLines: 2,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _passwordErrorText(DeleteUserScreenState state) {
    if (state is DeleteUserFailure &&
        state.type == DeleteUserFailureType.wrongPassword) {
      return 'パスワードが間違っています';
    }
    return null;
  }

  Future<void> deleteButtonEvent(
    BuildContext context,
    DeleteUserViewModel viewModel,
  ) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState.validate()) {
      await viewModel.deleteUser(password: _passwordController.text);
    }
  }
}
