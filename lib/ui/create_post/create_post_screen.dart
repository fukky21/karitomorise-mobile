import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../stores/signed_in_user_store.dart';
import '../../ui/components/bullet_texts.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_circle_avatar.dart';
import '../../ui/components/custom_raised_button.dart';
import '../../ui/components/custom_text_form_field.dart';
import '../../ui/components/scrollable_layout_builder.dart';
import '../../util/app_colors.dart';
import '../../util/validations.dart';
import 'create_post_view_model.dart';

class CreatePostScreenArguments {
  CreatePostScreenArguments({@required this.replyToNumber});

  final int replyToNumber;
}

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({this.args});

  static const route = '/create_post';
  final CreatePostScreenArguments args;

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEnabled = false;
  TextEditingController _controller;
  static const _bodyMaxLength = 140;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signedInUser = context.watch<SignedInUserStore>().getUser();

    return ChangeNotifierProvider(
      create: (_) => CreatePostViewModel(),
      child: Consumer<CreatePostViewModel>(
        builder: (context, viewModel, _) {
          final state = viewModel.getState();

          Future<void> _postButtonEvent() async {
            FocusScope.of(context).unfocus();
            if (_formKey.currentState.validate()) {
              await viewModel.createPost(
                body: _controller.text,
                replyToNumber: widget.args?.replyToNumber,
              );
            }
          }

          if (state is CreatePostFailure) {
            return Scaffold(
              appBar: simpleAppBar(context),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('エラーが発生しました'),
                      const SizedBox(height: 30),
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

          if (state is CreatePostSuccess) {
            return Scaffold(
              appBar: simpleAppBar(context),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('投稿しました！'),
                      const SizedBox(height: 30),
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

          return ModalProgressHUD(
            inAsyncCall: state is CreatePostInProgress,
            child: Scaffold(
              appBar: simpleAppBar(
                context,
                actions: [_postButton(postEvent: _postButtonEvent)],
              ),
              body: Form(
                key: _formKey,
                child: ScrollableLayoutBuilder(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _prohibitedMatters(),
                          const SizedBox(height: 25),
                          _avatarAndName(user: signedInUser),
                          const SizedBox(height: 7),
                          _replyToNumber(),
                          CustomTextFormField(
                            controller: _controller,
                            maxLength: _bodyMaxLength,
                            maxLines: 15,
                            validator: _bodyValidator,
                            onChanged: (text) {
                              // TODO(fukky21): スペースだけのときでも投稿できてしまうので修正する
                              if (text.isEmpty) {
                                setState(() {
                                  _isEnabled = false;
                                });
                              } else {
                                setState(() {
                                  _isEnabled = true;
                                });
                              }
                            },
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

  Widget _postButton({@required void Function() postEvent}) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 5),
        onPressed: _isEnabled ? postEvent : null,
        child: Text(
          '投稿',
          style: Theme.of(context).textTheme.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
                color: _isEnabled
                    ? Theme.of(context).primaryColor
                    : AppColors.grey60,
              ),
        ),
      ),
    );
  }

  Widget _prohibitedMatters() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).errorColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: const [
          Text(
            '〜禁止事項〜',
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 5),
          BulletTexts(
            texts: [
              '他人に不快な思いをさせる書き込み',
              '意図的な連投行為',
              '他サイトやアプリの宣伝',
              '金銭に関係する書き込み',
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatarAndName({@required AppUser user}) {
    return Container(
      child: Row(
        children: [
          CustomCircleAvatar(
            filePath: user?.avatar?.filePath,
            radius: 25,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              user?.name ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _replyToNumber() {
    if (widget.args?.replyToNumber != null) {
      return Container(
        padding: const EdgeInsets.only(top: 5, left: 10, bottom: 10),
        child: Text(
          '>>${widget.args.replyToNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }
    return Container();
  }

  String _bodyValidator(String text) {
    final errorMessages = <String>[
      Validations.blank(text: text),
      Validations.maxLength(text: text, maxLength: _bodyMaxLength),
    ];
    for (final errorMessage in errorMessages) {
      if (errorMessage != null) {
        return errorMessage;
      }
    }
    return null;
  }
}
