import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/post.dart';
import '../../store.dart';
import '../../ui/create_post/create_post_screen.dart';
import '../../ui/send_report/send_report_screen.dart';
import '../../ui/show_replies/show_replies_screen.dart';
import '../../ui/show_thread/show_thread_screen.dart';
import '../../util/app_colors.dart';
import '../../util/date_time_extension.dart';
import 'custom_circle_avatar.dart';
import 'custom_outline_button.dart';

class PostCell extends StatelessWidget {
  const PostCell({@required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) {
    final post = context.select((Store store) => store.posts[postId]);
    final user = context.select((Store store) => store.users[post?.uid]);
    final blockList = context.select((Store store) => store.blockList);

    if (post.isDeleted || blockList.contains(user?.id)) {
      return Container(
        color: AppColors.grey20,
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context, post),
            SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  post.isDeleted ? 'この投稿は削除されました' : 'このユーザーはブロックされています',
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: AppColors.grey20,
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, post),
          _body(context, user, post),
          const SizedBox(height: 10),
          _footer(context, post),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, Post post) {
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
            post?.number?.toString() ?? '',
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

  Widget _body(BuildContext context, AppUser user, Post post) {
    Widget _replyToButton = Container();
    if (post?.replyToNumber != null) {
      _replyToButton = Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: CustomOutlineButton(
          labelText: '>>${post.replyToNumber}',
          width: 80,
          height: 35,
          onPressed: () {
            Navigator.pushNamed(
              context,
              ShowThreadScreen.route,
              arguments: ShowThreadScreenArguments(post: post),
            );
          },
        ),
      );
    }

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
  }

  Widget _footer(BuildContext context, Post post) {
    Widget _replyCountButton = Container();
    if (post?.replyFromNumbers != null && post.replyFromNumbers.isNotEmpty) {
      _replyCountButton = ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).primaryColor,
          onPrimary: AppColors.white,
          shape: const CircleBorder(side: BorderSide.none),
        ),
        onPressed: () {
          Navigator.pushNamed(
            context,
            ShowRepliesScreen.route,
            arguments: ShowRepliesScreenArguments(post: post),
          );
        },
        child: Text('${post.replyFromNumbers.length}'),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _reportButton(context, post),
        Row(
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
                  arguments: CreatePostScreenArguments(
                    replyToNumber: post?.number,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _reportButton(BuildContext context, Post post) {
    return SizedBox(
      width: 60,
      height: 40,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          primary: Theme.of(context).errorColor,
          elevation: 0,
          side: BorderSide(width: 1, color: Theme.of(context).errorColor),
        ),
        onPressed: () {
          Navigator.pushNamed(
            context,
            SendReportScreen.route,
            arguments: SendReportScreenArguments(
              postNumber: post?.number,
            ),
          );
        },
        child: Center(
          child: Icon(
            Icons.outlined_flag,
            color: Theme.of(context).errorColor,
          ),
        ),
      ),
    );
  }
}
