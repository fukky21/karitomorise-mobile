import 'package:flutter/material.dart';

import '../../util/index.dart';
import 'search_result_screen.dart';

class SearchScreenArguments {
  SearchScreenArguments({@required this.initialValue});

  final String initialValue;
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({@required this.args});

  static const route = '/search';
  final SearchScreenArguments args;

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget?.args?.initialValue ?? '');
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(
        context,
        controller: _controller,
        onFieldSubmitted: (text) async {
          // TODO(fukky21): スペースだけのときでも遷移できてしまうので修正する
          if (text.isNotEmpty) {
            await Navigator.pushNamed(
              context,
              SearchResultScreen.route,
              arguments: SearchResultScreenArguments(keyword: text),
            );
            // 検索結果画面から戻ってくるとき、この画面はスルーする
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

PreferredSizeWidget _appBar(
  BuildContext context, {
  @required TextEditingController controller,
  @required void Function(String) onFieldSubmitted,
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(50),
    child: AppBar(
      titleSpacing: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => controller.clear(),
        )
      ],
      title: Material(
        color: AppColors.transparent,
        child: SizedBox(
          height: 40,
          child: TextFormField(
            autofocus: true,
            controller: controller,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: '直近の投稿を検索',
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(bottom: 10),
            ),
            onFieldSubmitted: onFieldSubmitted,
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
