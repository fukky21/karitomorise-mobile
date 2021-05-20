import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ui/components/custom_divider.dart';
import '../../ui/components/custom_raised_button.dart';
import '../../ui/components/post_cell.dart';
import '../../ui/searching/searching_screen.dart';
import '../../util/app_colors.dart';
import 'search_result_view_model.dart';

class SearchResultScreenArguments {
  SearchResultScreenArguments({@required this.keyword});

  final String keyword;
}

class SearchResultScreen extends StatefulWidget {
  const SearchResultScreen({@required this.args});

  static const route = '/search_result';
  final SearchResultScreenArguments args;

  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchResultViewModel(
        keyword: widget.args.keyword,
      )..init(),
      child: Scaffold(
        appBar: _appBar(
          context,
          keyword: widget.args.keyword,
          onTap: () {
            FocusScope.of(context).requestFocus(_focusNode);
            Navigator.pushNamed(
              context,
              SearchingScreen.route,
              arguments: SearchingScreenArguments(
                initialValue: widget.args?.keyword,
              ),
            );
          },
        ),
        body: Consumer<SearchResultViewModel>(
          builder: (context, viewModel, _) {
            final state = viewModel.getState() ?? SearchResultScreenLoading();

            if (state is SearchResultScreenLoadFailure) {
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

            if (state is SearchResultScreenLoadSuccess) {
              final posts = state.posts ?? [];
              final cells = <Widget>[];
              for (final post in posts) {
                cells.add(PostCell(post: post));
              }

              if (cells.isEmpty) {
                // 検索結果が0件のとき
                return Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('直近の投稿の検索結果は0件です'),
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

              return RefreshIndicator(
                onRefresh: () async => viewModel.init(),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: cells.length,
                  itemBuilder: (context, index) => cells[index],
                  separatorBuilder: (context, _) => CustomDivider(),
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

PreferredSizeWidget _appBar(
  BuildContext context, {
  @required String keyword,
  @required void Function() onTap,
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(50),
    child: AppBar(
      titleSpacing: 0,
      title: Material(
        color: AppColors.transparent,
        child: SizedBox(
          height: 40,
          child: TextFormField(
            initialValue: keyword,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(bottom: 10),
            ),
            onTap: onTap,
          ),
        ),
      ),
      backgroundColor: AppColors.grey10,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.3),
        child: Container(
          color: Theme.of(context).dividerColor,
          height: 0.3,
        ),
      ),
    ),
  );
}
