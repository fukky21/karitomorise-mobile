import 'package:flutter/material.dart';

import '../../widgets/components/index.dart';
import 'search_result_screen.dart';

class SearchScreenArguments {
  SearchScreenArguments({@required this.initialValue});

  final String initialValue;
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({@required this.args});

  static const route = 'search';
  final SearchScreenArguments args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchAppBar(
        context,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // TODO(Fukky21): 入力中の文字を全消しする機能を実装する
            },
          ),
        ],
        initialValue: args?.initialValue,
        autofocus: true,
        onFieldSubmitted: (text) async {
          // TODO(Fukky21): スペースだけのときでも遷移できてしまうので修正する
          if (text.isNotEmpty) {
            await Navigator.pushNamed(
              context,
              SearchResultScreen.route,
              arguments: SearchResultScreenArguments(keyword: text),
            );
            // この検索結果画面から戻ってくるとき、この画面はスルーする
            Navigator.of(context).pop();
          }
        },
      ),
      body: const Center(
        child: Text('SEARCHING'),
      ),
    );
  }
}
