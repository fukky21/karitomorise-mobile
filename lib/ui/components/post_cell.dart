import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/post.dart';
import '../../repositories/firebase_post_repository.dart';
import '../../repositories/shared_preference_repository.dart';
import '../../store.dart';
import '../../ui/components/custom_modal.dart';
import '../../ui/components/custom_snack_bar.dart';
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
        _OptionButton(parentContext: context, post: post),
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
}

class _OptionButton extends StatelessWidget {
  _OptionButton({@required this.parentContext, @required this.post});

  final BuildContext parentContext;
  final Post post;
  final _prefRepository = SharedPreferenceRepository();
  final _postRepository = FirebasePostRepository();

  @override
  Widget build(BuildContext context) {
    final currentUser = context.select((Store store) => store.currentUser);
    final actions = [reportAction(context), blockAction(context)];

    if (post != null && currentUser != null && post.uid == currentUser.uid) {
      actions.add(deleteAction(context));
    }

    return SizedBox(
      width: 45,
      height: 40,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          primary: Theme.of(context).primaryColor,
          elevation: 0,
          side: BorderSide(width: 1, color: Theme.of(context).primaryColor),
        ),
        onPressed: () {
          showCupertinoModalPopup<void>(
            context: context,
            builder: (context) => CupertinoActionSheet(
              actions: actions,
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
            ),
          );
        },
        child: Center(
          child: Icon(
            FontAwesomeIcons.ellipsisH,
            color: Theme.of(context).primaryColor,
            size: 15,
          ),
        ),
      ),
    );
  }

  CupertinoActionSheetAction reportAction(BuildContext context) {
    return CupertinoActionSheetAction(
      onPressed: () {
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          SendReportScreen.route,
          arguments: SendReportScreenArguments(postNumber: post?.number),
        );
      },
      child: const Text('通報する'),
    );
  }

  CupertinoActionSheetAction blockAction(BuildContext context) {
    return CupertinoActionSheetAction(
      onPressed: () async {
        Navigator.pop(context);
        try {
          if (post?.uid != null) {
            await _prefRepository.addToBlockList(uid: post.uid);
            final newBlockList = await _prefRepository.getBlockList();
            context.read<Store>().setBlockList(newBlockList);
            showSnackBar(parentContext, 'ブロックリストに追加しました');
          }
        } on Exception catch (e) {
          debugPrint(e.toString());
          showSnackBar(parentContext, 'エラーが発生しました');
        }
      },
      child: const Text('このユーザーをブロックする'),
    );
  }

  CupertinoActionSheetAction deleteAction(BuildContext context) {
    return CupertinoActionSheetAction(
      onPressed: () async {
        Navigator.pop(context);
        if (await showConfirmModal(context, '投稿を削除しますか？')) {
          try {
            await _postRepository.deletePost(postId: post?.id);
            final deletedPost = await _postRepository.getPost(
              number: post?.number,
            );
            context.read<Store>().addPost(post: deletedPost);
            showSnackBar(parentContext, '投稿を削除しました');
          } on Exception catch (e) {
            debugPrint(e.toString());
            showSnackBar(parentContext, 'エラーが発生しました');
          }
        }
      },
      child: Text(
        '削除する',
        style: TextStyle(color: Theme.of(context).errorColor),
      ),
    );
  }
}
