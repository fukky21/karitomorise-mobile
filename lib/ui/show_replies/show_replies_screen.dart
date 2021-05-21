import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/post.dart';
import '../../stores/users_store.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_circle_avatar.dart';
import '../../ui/components/custom_divider.dart';
import '../../ui/components/custom_outline_button.dart';
import '../../ui/components/custom_raised_button.dart';
import '../../util/app_colors.dart';
import '../../util/date_time_extension.dart';
import 'show_replies_view_model.dart';

class ShowRepliesScreenArguments {
  ShowRepliesScreenArguments({@required this.post});

  final Post post;
}

class ShowRepliesScreen extends StatelessWidget {
  const ShowRepliesScreen({@required this.args});

  static const route = '/show_replies';
  final ShowRepliesScreenArguments args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(context),
      body: ChangeNotifierProvider(
        create: (_) => ShowRepliesViewModel(sourcePost: args.post)..init(),
        child: Consumer<ShowRepliesViewModel>(
          builder: (context, viewModel, _) {
            final state = viewModel.getState() ?? ShowRepliesScreenLoading();

            if (state is ShowRepliesScreenLoadFailure) {
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

            if (state is ShowRepliesScreenLoadSuccess) {
              final posts = state.posts;

              final cells = <Widget>[];
              for (final post in posts) {
                cells.add(_Cell(post: post));
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

class _Cell extends StatelessWidget {
  const _Cell({@required this.post});

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

  Widget _body(BuildContext context) {
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

    final user = context.watch<UsersStore>().getUser(uid: post?.uid);

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
