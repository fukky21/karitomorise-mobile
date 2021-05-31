import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../stores/users_store.dart';
import '../../ui/components/advertising_cell.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_divider.dart';
import '../../ui/components/custom_raised_button.dart';
import '../../ui/components/post_cell.dart';
import '../../ui/create_post/create_post_screen.dart';
import '../../util/app_colors.dart';
import 'home_view_model.dart';

// フッターのホームアイコンを押したときに一番上までスクロールする
ScrollController _scrollController;
void homeScreenScrollToTop() {
  if (_scrollController.hasClients) {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }
}

class HomeScreen extends StatefulWidget {
  static const route = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      create: (context) => HomeViewModel(
        usersStore: context.read<UsersStore>(),
      )..init(),
      child: Scaffold(
        appBar: simpleAppBar(context, title: _appBarTitle),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, CreatePostScreen.route);
          },
          child: const Icon(Icons.edit, color: AppColors.white),
        ),
        body: Consumer<HomeViewModel>(
          builder: (context, viewModel, _) {
            final state = viewModel.getState() ?? HomeScreenLoading();

            if (state is HomeScreenLoadFailure) {
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
                          await viewModel.init();
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is HomeScreenLoadSuccess) {
              final posts = state.posts;
              final cells = <Widget>[];

              for (var i = 0; i < posts.length; i++) {
                cells.add(PostCell(post: posts[i]));
                if (i >= 10 && i % 10 == 0) {
                  // 10投稿ごとに広告を挿入する
                  final adCell = AdvertisingCell();
                  cells.add(adCell);
                }
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
                            await viewModel.init();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => viewModel.init(),
                child: ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (index == cells.length) {
                      if (state.isFetchabled) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          viewModel.fetch();
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
