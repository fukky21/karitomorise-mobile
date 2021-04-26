import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../blocs/authentication_bloc/index.dart';
import '../../blocs/show_event_screen_bloc/index.dart';
import '../../models/index.dart';
import '../../providers/index.dart';
import '../../utils/index.dart';
import '../../widgets/components/index.dart';
import 'show_event_comments_screen.dart';
import 'show_user_screen.dart';

class ShowEventScreenArguments {
  ShowEventScreenArguments({@required this.eventId});

  final String eventId;
}

class ShowEventScreen extends StatelessWidget {
  const ShowEventScreen({@required this.args});

  static const route = '/show_event';
  static const _appBarTitle = '募集';
  final ShowEventScreenArguments args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShowEventScreenBloc>(
      create: (context) {
        return ShowEventScreenBloc(
          context: context,
        )..add(Initialized(eventId: args.eventId));
      },
      child: BlocBuilder<ShowEventScreenBloc, ShowEventScreenState>(
        builder: (context, state) {
          if (state is InitializeInProgress) {
            return Scaffold(
              appBar: simpleAppBar(context),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (state is InitializeFailure) {
            return _eventNotFoundView(context);
          }
          if (state is InitializeSuccess) {
            return _initializeSuccessView(context, state);
          }
          return Container();
        },
      ),
    );
  }

  Widget _eventNotFoundView(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(context),
      body: const Center(
        child: Text('この募集は表示できません'),
      ),
    );
  }

  Widget _initializeSuccessView(BuildContext context, InitializeSuccess state) {
    return Consumer<EventsProvider>(
      builder: (context, provider, _) {
        final _event = provider.get(eventId: args.eventId);
        if (_event == null) {
          return _eventNotFoundView(context);
        }
        return RefreshIndicator(
          onRefresh: () async {
            context
                .read<ShowEventScreenBloc>()
                .add(Initialized(eventId: args.eventId));
          },
          child: Scaffold(
            appBar: simpleAppBar(context, title: _appBarTitle),
            bottomNavigationBar: _bottomBar(context, _event),
            body: ScrollableLayoutBuilder(
              alwaysScrollable: true,
              child: Container(
                padding: const EdgeInsets.only(bottom: 50),
                child: Column(
                  children: [
                    _userCell(_event.uid),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_event.description ?? '(募集文なし)'),
                          const SizedBox(height: 20),
                          Text(
                            _event.updatedAt?.toYMDHHMMString() ?? '',
                            style: const TextStyle(color: AppColors.grey60),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    CustomDivider(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: _actionButtons(context, _event),
                    ),
                    CustomDivider(),
                    const SizedBox(height: 15),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      margin: const EdgeInsets.only(bottom: 5),
                      child: const Text(
                        '最近のコメント',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _resentCommentView(state.comments),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bottomBar(BuildContext context, AppEvent event) {
    final _width = MediaQuery.of(context).size.width;
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      cubit: context.watch<AuthenticationBloc>(),
      builder: (context, state) {
        if (state is AuthenticationSuccess &&
            state.currentUser.uid == event?.uid) {
          return BottomAppBar(
            child: Container(
              height: 60,
              padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: _width * 0.35,
                    child: CustomOutlineButton(
                      labelText: '募集を削除する',
                      isDanger: true,
                      onPressed: () {
                        // TODO(Fukky21): 募集削除機能を実装する
                      },
                    ),
                  ),
                  SizedBox(
                    width: _width * 0.5,
                    child: CustomRaisedButton(
                      labelText: 'コメントする',
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          ShowEventCommentsScreen.route,
                          arguments: ShowEventCommentsScreenArguments(
                            eventId: args.eventId,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const BottomAppBar();
      },
    );
  }

  Widget _actionButtons(BuildContext context, AppEvent event) {
    const _size = 23.0;

    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      cubit: context.watch<AuthenticationBloc>(),
      builder: (context, state) {
        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommentButton(
                eventId: event?.id,
                size: _size,
                commentCount: event?.commentCount ?? 0,
              ),
              FavoriteButton(
                eventId: event?.id,
                isSignedIn: state is AuthenticationSuccess,
                size: _size,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _userCell(String uid) {
    const _height = 65.0;

    return Consumer<UsersProvider>(
      builder: (context, provider, _) {
        final _user = provider.get(uid: uid);
        return GestureDetector(
          onTap: () {
            if (uid != null) {
              Navigator.pushNamed(
                context,
                ShowUserScreen.route,
                arguments: ShowUserScreenArguments(uid: uid),
              );
            }
          },
          child: Container(
            width: double.infinity,
            height: _height,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: Row(
              children: [
                CustomCircleAvatar(
                  filePath: _user?.avatar?.iconFilePath,
                  radius: (_height - 15) / 2,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    _user?.displayName ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _resentCommentView(List<EventComment> comments) {
    final commentCells = <Widget>[];
    for (final comment in comments) {
      commentCells.add(_commentCell(comment));
    }

    if (commentCells.isEmpty) {
      return Container(
        height: 150,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: const Center(
          child: Text('コメントはありません'),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: commentCells,
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
}
