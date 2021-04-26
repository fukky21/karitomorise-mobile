import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/search_tab_bloc/index.dart';
import '../../widgets/components/index.dart';
import '../../widgets/screens/index.dart';

class SearchTab extends StatelessWidget {
  static const _appBarTitle = 'さがす';

  final hotwords = [
    'ナルヒメ',
    'ラージャン',
    '百竜夜行',
    'ナルヒメ',
    'ラージャン',
    '百竜夜行',
    'ナルヒメ',
    'ラージャン',
    '百竜夜行',
    'ナルヒメ',
    'ラージャン',
    '百竜夜行',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(
        context,
        title: _appBarTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, SearchScreen.route),
          ),
        ],
      ),
      body: BlocProvider<SearchTabBloc>(
        create: (context) =>
            SearchTabBloc(context: context)..add(Initialized()),
        child: BlocBuilder<SearchTabBloc, SearchTabState>(
          builder: (context, state) {
            if (state is InitializeFailure) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('読み込みに失敗しました'),
                    const SizedBox(height: 30),
                    CustomRaisedButton(
                      labelText: '再読み込み',
                      onPressed: () {
                        context.read<SearchTabBloc>().add(Initialized());
                      },
                    ),
                  ],
                ),
              );
            }
            if (state is InitializeSuccess) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<SearchTabBloc>().add(Initialized());
                },
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
                            'HOTワード🔥',
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

/*
Material(
          color: AppColors.grey20,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
 */
