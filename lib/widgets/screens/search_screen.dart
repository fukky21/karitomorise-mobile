import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/index.dart';

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
      appBar: _searchAppBar(
        context,
        initialValue: args?.initialValue ?? '',
      ),
      body: Container(),
    );
  }

  PreferredSizeWidget _searchAppBar(
    BuildContext context, {
    @required String initialValue,
  }) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 7,
        actions: [
          Container(
            margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 5),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'キャンセル',
                style: Theme.of(context)
                    .textTheme
                    .subtitle2
                    .copyWith(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
        ],
        title: Hero(
          tag: 'search_bar',
          child: Material(
            color: AppColors.transparent,
            child: Container(
              padding: const EdgeInsets.only(bottom: 10),
              height: 40,
              child: TextFormField(
                autofocus: true,
                initialValue: initialValue,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: AppColors.grey20,
                  hintText: 'キーワード検索',
                  hintStyle: TextStyle(color: AppColors.grey60),
                  prefixIcon: Icon(Icons.search, color: AppColors.grey60),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  contentPadding: EdgeInsets.only(left: 10),
                ),
                onFieldSubmitted: (text) {
                  debugPrint(text);
                },
              ),
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
}
