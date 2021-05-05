import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../notifiers/index.dart';
import '../../repositories/index.dart';
import '../../util/index.dart';
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
      create: (_) => HomeTabStateNotifier(
        postRepository: context.read<FirebasePostRepository>(),
        usersNotifier: context.read<UsersNotifier>(),
      ),
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
                          await notifier.init();
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
                cells.add(PostCell(post: post));
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
                      if (state.isFetchabled) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          notifier.fetch();
                        });
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: const CircularProgressIndicator(),
                          ),
                        );
                      } else {
                        return Container();
                      }
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
