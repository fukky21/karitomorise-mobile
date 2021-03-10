import 'package:flutter/material.dart';

import '../../utils/index.dart';
import '../../widgets/screens/index.dart';

class SearchTab extends StatefulWidget {
  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
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
    return Scaffold(
      appBar: _searchAppBar(context, focusNode: _focusNode),
      body: const Center(
        child: Text('SEARCH'),
      ),
    );
  }

  PreferredSizeWidget _searchAppBar(
    BuildContext context, {
    @required FocusNode focusNode,
  }) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
        title: Hero(
          tag: 'search_bar',
          child: Material(
            color: AppColors.transparent,
            child: Container(
              padding: const EdgeInsets.only(bottom: 10),
              height: 40,
              child: TextFormField(
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
                onTap: () {
                  FocusScope.of(context).requestFocus(focusNode);
                  Navigator.pushNamed(
                    context,
                    SearchScreen.route,
                  );
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
