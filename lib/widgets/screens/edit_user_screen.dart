import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import '../../models/index.dart';
import '../../notifiers/index.dart';
import '../../repositories/index.dart';
import '../../util/index.dart';
import '../../widgets/components/index.dart';
import 'select_avatar_screen.dart';

class EditUserScreenArguments {
  EditUserScreenArguments({@required this.name, @required this.avatar});

  final String name;
  final AppUserAvatar avatar;
}

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({@required this.args});

  static const route = '/edit_user';
  final EditUserScreenArguments args;

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  static const _appBarTitle = '変更';
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controller;
  AppUserAvatar _avatar;
  static const _nameMaxLength = 20;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.args?.name ?? '');
    _avatar = widget.args?.avatar;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditUserScreenStateNotifier(
        userRepository: context.read<FirebaseUserRepository>(),
      ),
      child: Consumer<EditUserScreenStateNotifier>(
          builder: (context, notifier, _) {
        final state = notifier?.state;

        if (state is UpdateUserFailure) {
          return Scaffold(
            appBar: simpleAppBar(context),
            body: const Center(
              child: Text('エラーが発生しました'),
            ),
          );
        }

        if (state is UpdateUserSuccess) {
          return Scaffold(
            appBar: simpleAppBar(context),
            body: const Center(
              child: Text('変更しました'),
            ),
          );
        }

        return ModalProgressHUD(
          inAsyncCall: state is UpdateUserInProgress,
          child: Scaffold(
            appBar: simpleAppBar(
              context,
              title: _appBarTitle,
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 15),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState.validate()) {
                        await notifier
                            .updateUser(
                          name: _controller.text,
                          avatar: _avatar,
                        )
                            .then((value) async {
                          if (value) {
                            await context
                                .read<AuthenticationNotifier>()
                                .updateUser();
                          }
                        });
                      }
                    },
                    child: Text(
                      '保存',
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: state is UpdateUserInProgress
                                ? AppColors.grey60
                                : Theme.of(context).primaryColor,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            body: Form(
              key: _formKey,
              child: ScrollableLayoutBuilder(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 50,
                  ),
                  child: Column(
                    children: [
                      CustomCircleAvatar(
                        filePath: _avatar?.filePath,
                        radius: 50,
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            SelectAvatarScreen.route,
                          ) as AppUserAvatar;
                          if (result != null) {
                            if (mounted) {
                              setState(() {
                                _avatar = result;
                              });
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 30),
                      CustomTextFormField(
                        labelText: 'ユーザー名',
                        controller: _controller,
                        maxLength: _nameMaxLength,
                        validator: _nameValidator,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  String _nameValidator(String name) {
    final errorMessages = <String>[
      Validations.blank(text: name),
      Validations.maxLength(text: name, maxLength: _nameMaxLength),
    ];
    for (final errorMessage in errorMessages) {
      if (errorMessage != null) {
        return errorMessage;
      }
    }
    return null;
  }
}
