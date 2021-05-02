import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/index.dart';
import '../../notifiers/index.dart';
import '../../utils/index.dart';
import '../../widgets/components/index.dart';
import '../../widgets/screens/index.dart';

// フッターのホームアイコンを押したときに一番上までスクロールする処理
ScrollController _scrollController;
void homeTabScrollToTop() {
  if (_scrollController.hasClients) {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }
}

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static const _appBarTitle = 'ホーム';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeTabStateNotifier(),
      child: Scaffold(
        appBar: simpleAppBar(context, title: _appBarTitle),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, CreatePostScreen.route);
          },
          child: const Icon(Icons.add, color: AppColors.white),
        ),
        body: Consumer<HomeTabStateNotifier>(
          builder: (context, notifier, _) {
            final state = notifier?.state ?? HomeTabLoading();

            if (state is HomeTabLoadFailure) {
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
                          await context.read<HomeTabStateNotifier>().init();
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is HomeTabLoadSuccess) {
              final posts = state.posts;
              final cells = <Widget>[];

              for (final post in posts) {
                cells.add(_PostCell(post: post));
              }

              if (cells.isEmpty) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('表示できる投稿がありません'),
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

              return RefreshIndicator(
                onRefresh: () async {
                  await notifier.init();
                },
                child: ListView.separated(
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    if (index == cells.length) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        notifier.fetch();
                      });
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    }
                    return cells[index];
                  },
                  separatorBuilder: (context, _) => CustomDivider(),
                  itemCount: cells.length + 1, // インジケータ表示のために+1している
                ),
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

class _PostCell extends StatelessWidget {
  const _PostCell({@required this.post});

  final Post post;

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
    Widget _anchorButton = Container();
    if (post?.anchorId != null) {
      _anchorButton = Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: CustomOutlineButton(
          labelText: '>>${post.anchorId}',
          width: 80,
          height: 35,
          onPressed: () {
            // TODO(fukky21): スレッド画面へ遷移する
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
            filePath: post?.user?.avatar?.iconFilePath,
            radius: 25,
            onTap: () {
              // TODO(fukky21): ユーザー詳細画面へ遷移する
            },
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post?.user?.displayName ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                _anchorButton,
                Text(post?.body ?? '(本文なし)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context) {
    Widget _replyCountButton = Container();
    if (post?.replyIdList != null && post.replyIdList.isNotEmpty) {
      _replyCountButton = ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).primaryColor,
          onPrimary: AppColors.white,
          shape: const CircleBorder(
            side: BorderSide.none,
          ),
        ),
        onPressed: () {
          // TODO(fukky21): 返信一覧画面へ遷移する
        },
        child: Text('${post.replyIdList.length}'),
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
            // TODO(fukky21): 返信ボタン機能を実装する
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.grey20,
      child: InkWell(
        onTap: () {
          // TODO(fukky21): 詳細画面へ遷移する
        },
        child: Container(
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
        ),
      ),
    );
  }
}
