import 'package:flutter/material.dart';

import '../../models/index.dart';
import '../../util/index.dart';
import '../../widgets/components/index.dart';
import 'search_screen.dart';

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
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = Post(
      id: 'tmp',
      number: 5000,
      uid: null,
      replyToNumber: 4900,
      body: '検索結果です検索結果です検索結果です検索結果です検索結果です検索結果です',
      replyFromNumbers: [5001, 5002],
      createdAt: DateTime.now(),
    );

    final cells = <Widget>[];
    for (var i = 0; i < 10; i++) {
      cells.add(PostCell(post: post));
    }

    return Scaffold(
      appBar: _appBar(
        context,
        keyword: widget.args?.keyword ?? '',
        onTap: () {
          FocusScope.of(context).requestFocus(_focusNode);
          Navigator.pushNamed(
            context,
            SearchScreen.route,
            arguments: SearchScreenArguments(
              initialValue: widget.args?.keyword,
            ),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO(fukky21): リフレッシュ機能を実装する
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: cells.length,
          itemBuilder: (context, index) {
            return cells[index];
          },
          separatorBuilder: (context, _) => CustomDivider(),
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
            decoration: const InputDecoration(border: InputBorder.none),
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
