import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:provider/provider.dart';

import '../../blocs/authentication_bloc/index.dart';
import '../../models/index.dart';
import '../../providers/index.dart';
import '../../utils/index.dart';
import '../../widgets/screens/index.dart';
import 'comment_button.dart';
import 'custom_circle_avatar.dart';
import 'favorite_button.dart';
import 'share_button.dart';

class EventCell extends StatelessWidget {
  const EventCell({@required this.eventId, @required this.onTap});

  final String eventId;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Consumer<EventsProvider>(
      builder: (context, provider, _) {
        final _event = provider.get(eventId: eventId);

        return Material(
          color: AppColors.grey20,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _userPart(context, _event?.uid),
                      _elapsedTimeText(context, _event),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(_event.description ?? '(募集文なし)'),
                  ),
                  const SizedBox(height: 10),
                  _tags(context, _event),
                  const SizedBox(height: 10),
                  _actionButtons(context, _event),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _userPart(BuildContext context, String uid) {
    return Consumer<UsersProvider>(
      builder: (context, provider, _) {
        final _user = provider.get(uid: uid);
        return Expanded(
          child: Row(
            children: [
              CustomCircleAvatar(
                filePath: _user?.avatar?.iconFilePath,
                radius: 25,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    ShowUserScreen.route,
                    arguments: ShowUserScreenArguments(uid: uid),
                  );
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _user?.displayName ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _elapsedTimeText(BuildContext context, AppEvent event) {
    final dateTime = event?.updatedAt;
    String text;
    if (dateTime != null) {
      final diff = DateTime.now().difference(dateTime);
      final sec = diff.inSeconds;
      if (sec <= 60) {
        text = '1分以内';
      } else if (sec <= 60 * 60) {
        text = '${diff.inMinutes}分前';
      } else if (sec <= 60 * 60 * 24) {
        text = '${diff.inHours}時間前';
      } else {
        text = dateTime.toYMDString();
      }
    }
    return Text(
      text ?? '',
      style: Theme.of(context).textTheme.caption,
    );
  }

  Widget _tags(BuildContext context, AppEvent event) {
    if (event != null) {
      final labels = <String>[];
      if (event.type?.name != null) {
        labels.add(event.type.name);
      }
      if (event.questRank?.name != null) {
        labels.add(event.questRank.name);
      }
      if (event.targetLevel?.name != null) {
        labels.add(event.targetLevel.name);
      }
      if (event.playTime?.name != null) {
        labels.add(event.playTime.name);
      }

      return Tags(
        spacing: 5,
        runSpacing: 5,
        itemCount: labels.length,
        itemBuilder: (index) {
          return ItemTags(
            index: index,
            title: labels[index],
            textColor: AppColors.white,
            elevation: 0,
            activeColor: Theme.of(context).primaryColor,
            pressEnabled: false,
          );
        },
      );
    }

    return Container();
  }

  Widget _actionButtons(BuildContext context, AppEvent event) {
    const _size = 20.0;

    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      cubit: context.watch<AuthenticationBloc>(),
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
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
}
