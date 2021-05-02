import 'package:flutter/material.dart';

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
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO(fukky21): ホットワードをリフレッシュする
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
                    '🔥HOTワード🔥',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 15),
                _hotwordCellList(context, hotwords),
              ],
            ),
          ),
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
