import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/index.dart';
import '../../notifiers/index.dart';
import '../../util/index.dart';
import '../../widgets/screens/index.dart';
import 'custom_circle_avatar.dart';
import 'custom_outline_button.dart';

class PostCell extends StatelessWidget {
  const PostCell({@required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.grey20,
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          _body(context),
          _footer(context),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final dateTime = post?.createdAt;
    var elapsedTimeText = '';
    if (dateTime != null) {
      final diff = DateTime.now().difference(dateTime);
      final sec = diff.inSeconds;
      if (sec <= 60) {
        elapsedTimeText = '1分以内';
      } else if (sec <= 60 * 60) {
        elapsedTimeText = '${diff.inMinutes}分前';
      } else if (sec <= 60 * 60 * 24) {
        elapsedTimeText = '${diff.inHours}時間前';
      } else {
        elapsedTimeText = dateTime.toYMDString();
      }
    }

    return Container(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            post?.id?.toString() ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            elapsedTimeText,
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    Widget _replyToButton = Container();
    if (post?.replyToId != null) {
      _replyToButton = Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: CustomOutlineButton(
          labelText: '>>${post.replyToId}',
          width: 80,
          height: 35,
          onPressed: () {
            // TODO(fukky21): スレッド画面へ遷移する
          },
        ),
      );
    }

    return Consumer<UsersNotifier>(builder: (context, notifier, _) {
      final user = notifier?.get(uid: post?.uid);

      return Container(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCircleAvatar(
              filePath: user?.avatar?.filePath,
              radius: 25,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  _replyToButton,
                  Text(post?.body ?? '(本文なし)'),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _footer(BuildContext context) {
    Widget _replyCountButton = Container();
    if (post?.replyFromIdList != null && post.replyFromIdList.isNotEmpty) {
      _replyCountButton = ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).primaryColor,
          onPrimary: AppColors.white,
          shape: const CircleBorder(side: BorderSide.none),
        ),
        onPressed: () {
          // TODO(fukky21): 返信一覧画面へ遷移する
        },
        child: Text('${post.replyFromIdList.length}'),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _replyCountButton,
        CustomOutlineButton(
          labelText: '返信する',
          width: 100,
          height: 40,
          onPressed: () {
            Navigator.pushNamed(
              context,
              CreatePostScreen.route,
              arguments: CreatePostScreenArguments(replyToId: post?.id),
            );
          },
        ),
      ],
    );
  }
}
