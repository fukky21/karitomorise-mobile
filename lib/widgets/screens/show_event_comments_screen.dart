import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../blocs/authentication_bloc/index.dart';
import '../../blocs/show_event_comments_screen_bloc/index.dart';
import '../../models/index.dart';
import '../../providers/index.dart';
import '../../utils/index.dart';
import '../../widgets/components/index.dart';
import 'show_user_screen.dart';

class ShowEventCommentsScreenArguments {
  ShowEventCommentsScreenArguments({@required this.eventId});

  final String eventId;
}

class ShowEventCommentsScreen extends StatefulWidget {
  const ShowEventCommentsScreen({@required this.args});

  static const route = 'show_event_comments';
  final ShowEventCommentsScreenArguments args;

  @override
  _ShowEventCommentsScreenState createState() =>
      _ShowEventCommentsScreenState();
}

class _ShowEventCommentsScreenState extends State<ShowEventCommentsScreen> {
  static const _appBarTitle = 'コメント';
  TextEditingController _messageController;
  bool _isSubmittable;

  static const _messageMaxLength = 400;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _isSubmittable = false;
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShowEventCommentsScreenBloc>(
      create: (context) {
        return ShowEventCommentsScreenBloc(context: context)
          ..add(Initialized(eventId: widget.args.eventId));
      },
      child: Scaffold(
        appBar: simpleAppBar(context, title: _appBarTitle),
        body: BlocBuilder<ShowEventCommentsScreenBloc,
            ShowEventCommentsScreenState>(
          builder: (context, state) {
            if (state == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Column(
              children: [
                _messageList(state.comments),
                _inputBar(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _messageList(List<EventComment> comments) {
    return Flexible(
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: comments.length,
        itemBuilder: (context, index) => _commentCell(comments[index]),
        reverse: true,
      ),
    );
  }

  Widget _commentCell(EventComment comment) {
    return Consumer<UsersProvider>(
      builder: (context, provider, _) {
        final _user = provider.get(uid: comment.uid);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: CustomCircleAvatar(
                  filePath: _user?.avatar?.iconFilePath,
                  radius: 25,
                  onTap: () {
                    if (_user?.id != null) {
                      Navigator.pushNamed(
                        context,
                        ShowUserScreen.route,
                        arguments: ShowUserScreenArguments(uid: _user?.id),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user?.displayName ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Container(
                              child: Bubble(
                                nip: BubbleNip.leftTop,
                                color: AppColors.grey60,
                                child: Text(
                                  comment.message ?? '(表示できません)',
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                child: Text(
                                  comment.createdAt?.toHHMMString() ?? '',
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage(BuildContext context) {
    if (_isSubmittable) {
      final text = _messageController.text;
      if (text.length <= _messageMaxLength) {
        setState(() {
          _isSubmittable = false;
          context
              .read<ShowEventCommentsScreenBloc>()
              .add(CreateCommentOnPressed(message: text));
          _messageController.clear();
        });
      } else {
        showErrorModal(context, '$_messageMaxLength文字以内で送信してください');
      }
    }
  }

  Widget _inputBar(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 0.3,
            ),
          ),
        ),
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is AuthenticationSuccess) {
              return Row(
                children: <Widget>[
                  Flexible(
                    child: Container(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration.collapsed(
                          hintText: 'メッセージを入力',
                        ),
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 5,
                        onChanged: (text) {
                          setState(() {
                            _isSubmittable = text.isNotEmpty;
                          });
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    padding: const EdgeInsets.all(0),
                    color: _isSubmittable
                        ? Theme.of(context).primaryColor
                        : AppColors.grey60,
                    onPressed: () => _sendMessage(context),
                  ),
                ],
              );
            }
            return Container(
              child: const Center(
                child: Text('サインインするとコメントできます'),
              ),
            );
          },
        ),
      ),
    );
  }
}
