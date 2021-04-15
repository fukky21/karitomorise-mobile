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
            return _initializeSuccessView(context);
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

  Widget _initializeSuccessView(BuildContext context) {
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
                padding: const EdgeInsets.only(top: 20, bottom: 50),
                child: Column(
                  children: [
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
                    const SizedBox(height: 30),
                    _headline('募集ユーザー'),
                    CustomDivider(),
                    _userCell(_event.uid),
                    CustomDivider(),
                    const SizedBox(height: 30),
                    CustomRaisedButton(
                      labelText: 'コメントを確認する',
                      width: MediaQuery.of(context).size.width * 0.7,
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
                      labelText: '編集する',
                      onPressed: () {
                        // TODO(Fukky21): 募集編集機能を実装する
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
          width: MediaQuery.of(context).size.width * 0.6,
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
              ShareButton(
                eventId: event?.id,
                size: _size,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _headline(String text) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      margin: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _userCell(String uid) {
    const _height = 65.0;

    return Consumer<UsersProvider>(
      builder: (context, provider, _) {
        final _user = provider.get(uid: uid);
        return Material(
          color: AppColors.grey20,
          child: InkWell(
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
              padding: const EdgeInsets.only(
                top: 5,
                left: 15,
                right: 5,
                bottom: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CustomCircleAvatar(
                          filePath: _user?.avatar?.iconFilePath,
                          radius: (_height - 15) / 2,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
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
                  const Icon(Icons.chevron_right_sharp),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailCell(String title, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(label ?? '未設定'),
        ],
      ),
    );
  }
}
