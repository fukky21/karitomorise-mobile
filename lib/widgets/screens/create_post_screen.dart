import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import '../../models/index.dart';
import '../../notifiers/index.dart';
import '../../repositories/index.dart';
import '../../util/index.dart';
import '../../widgets/components/index.dart';

class CreatePostScreen extends StatefulWidget {
  static const route = '/create_post';

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
    final authState = context.read<AuthenticationNotifier>().state;

    if (authState is AuthenticationSuccess) {
      final user = authState.user;

      return ChangeNotifierProvider(
        create: (context) => CreatePostScreenStateNotifier(
          postRepository: context.read<FirebasePostRepository>(),
        ),
        child: Consumer<CreatePostScreenStateNotifier>(
          builder: (context, notifier, _) {
            final state = notifier?.state;

            if (state is CreatePostFailure) {
              return Scaffold(
                appBar: simpleAppBar(context),
                body: const Center(
                  child: Text('エラーが発生しました'),
                ),
              );
            }

            if (state is CreatePostSuccess) {
              return Scaffold(
                appBar: simpleAppBar(context),
                body: const Center(
                  child: Text('投稿しました'),
                ),
              );
            }

            return ModalProgressHUD(
              inAsyncCall: state is CreatePostInProgress,
              child: Scaffold(
                appBar: simpleAppBar(
                  context,
                  actions: [
                    _postButton(notifier: notifier),
                  ],
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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).errorColor,
                                ),
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
                            ),
                            const SizedBox(height: 25),
                            Container(
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
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 7),
                            CustomTextFormField(
                              controller: _controller,
                              maxLength: _bodyMaxLength,
                              maxLines: 15,
                              validator: _bodyValidator,
                              onChanged: (text) {
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

    // ここには来ないはず
    return Scaffold(
      appBar: simpleAppBar(context),
      body: const Center(
        child: Text('エラーが発生しました'),
      ),
    );
  }

  Widget _postButton({@required CreatePostScreenStateNotifier notifier}) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 5),
        onPressed: _isEnabled
            ? () {
                FocusScope.of(context).unfocus();
                if (_formKey.currentState.validate()) {
                  notifier.createPost(body: _controller.text);
                }
              }
            : null,
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
