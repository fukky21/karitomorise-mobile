import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/post.dart';
import '../../store.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_circle_avatar.dart';
import '../../ui/components/custom_divider.dart';
import '../../ui/components/custom_outline_button.dart';
import '../../ui/components/custom_raised_button.dart';
import '../../util/app_colors.dart';
import '../../util/date_time_extension.dart';
import 'show_thread_view_model.dart';

class ShowThreadScreenArguments {
  ShowThreadScreenArguments({@required this.post});

  final Post post;
}

class ShowThreadScreen extends StatelessWidget {
  const ShowThreadScreen({@required this.args});

  static const route = '/show_thread';
  final ShowThreadScreenArguments args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(context, title: 'スレッド'),
      body: ChangeNotifierProvider(
        create: (context) => ShowThreadViewModel(
          sourcePost: args.post,
          store: context.read<Store>(),
        )..init(),
        child: Consumer<ShowThreadViewModel>(
          builder: (context, viewModel, _) {
            final state = viewModel.getState() ?? ShowThreadScreenLoading();

            if (state is ShowThreadScreenLoadFailure) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('エラーが発生しました'),
                      const SizedBox(height: 30),
                      CustomRaisedButton(
                        labelText: '再読み込み',
                        onPressed: () async => viewModel.init(),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ShowThreadScreenLoadSuccess) {
              final postIdList = state.postIdList;

              final cells = <Widget>[];
              for (final postId in postIdList) {
                cells.add(_ThreadCell(postId: postId));
              }

              return ListView.separated(
                itemBuilder: (context, index) => cells[index],
                separatorBuilder: (context, _) => CustomDivider(),
                itemCount: cells.length,
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

class _ThreadCell extends StatelessWidget {
  const _ThreadCell({@required this.postId});

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
          onPressed: null,
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
}
