import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/index.dart';
import '../../notifiers/index.dart';
import '../../repositories/index.dart';
import '../../util/index.dart';
import '../../widgets/components/index.dart';

class ThreadScreenArguments {
  ThreadScreenArguments({@required this.post});

  final Post post;
}

class ThreadScreen extends StatelessWidget {
  const ThreadScreen({@required this.args});

  static const route = '/thread';
  final ThreadScreenArguments args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(context),
      body: ChangeNotifierProvider(
        create: (context) => ThreadScreenStateNotifier(
          sourcePost: args.post,
          postRepository: context.read<FirebasePostRepository>(),
        ),
        child: Consumer<ThreadScreenStateNotifier>(
          builder: (context, notifier, _) {
            final state = notifier?.state ?? ThreadScreenLoading();

            if (state is ThreadScreenLoadFailure) {
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
                        onPressed: () async {
                          await notifier.init();
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ThreadScreenLoadSuccess) {
              final posts = state.posts;

              final cells = <Widget>[];
              for (final post in posts) {
                cells.add(_ThreadCell(post: post));
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
  const _ThreadCell({@required this.post});

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
          onPressed: null,
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
}
