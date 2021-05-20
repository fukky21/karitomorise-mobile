import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_divider.dart';
import '../../ui/components/custom_raised_button.dart';
import '../../ui/components/scrollable_layout_builder.dart';
import '../../ui/search_result/search_result_screen.dart';
import '../../ui/searching/searching_screen.dart';
import 'search_view_model.dart';

class SearchScreen extends StatelessWidget {
  static const route = '/search';
  static const _appBarTitle = 'さがす';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(
        context,
        title: _appBarTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, SearchingScreen.route);
            },
          ),
        ],
      ),
      body: ChangeNotifierProvider(
        create: (_) => SearchViewModel()..init(),
        child: Consumer<SearchViewModel>(
          builder: (context, viewModel, _) {
            final state = viewModel.getState() ?? SearchScreenLoading();

            if (state is SearchScreenLoadFailure) {
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

            if (state is SearchScreenLoadSuccess) {
              return RefreshIndicator(
                onRefresh: () async => viewModel.init(),
                child: ScrollableLayoutBuilder(
                  alwaysScrollable: true,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          margin: const EdgeInsets.only(bottom: 5),
                          child: const Text(
                            '🔥HOTワード🔥',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _hotwordCellList(context, state.hotwords),
                      ],
                    ),
                  ),
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

  Widget _hotwordCellList(BuildContext context, List<String> hotwords) {
    if (hotwords.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(
          child: Text('データを取得できませんでした'),
        ),
      );
    }
    final parts = <Widget>[CustomDivider()];
    for (final hotword in hotwords) {
      parts
        ..add(
          Material(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  SearchResultScreen.route,
                  arguments: SearchResultScreenArguments(
                    keyword: hotword ?? '',
                  ),
                );
              },
              child: SizedBox(
                height: 50,
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(hotword ?? ''),
                ),
              ),
            ),
          ),
        )
        ..add(CustomDivider());
    }
    return Column(children: parts);
  }
}
