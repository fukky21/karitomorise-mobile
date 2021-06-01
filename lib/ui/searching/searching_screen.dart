import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../ui/components/custom_divider.dart';
import '../../ui/search_result/search_result_screen.dart';
import '../../ui/searching/searching_view_model.dart';
import '../../util/app_colors.dart';

class SearchingScreenArguments {
  SearchingScreenArguments({@required this.initialValue});

  final String initialValue;
}

class SearchingScreen extends StatefulWidget {
  const SearchingScreen({this.args});

  static const route = '/searching';
  final SearchingScreenArguments args;

  @override
  _SearchingScreenState createState() => _SearchingScreenState();
}

class _SearchingScreenState extends State<SearchingScreen> {
  TextEditingController _controller;
  String _currentInput;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.args?.initialValue ?? '');
    _currentInput = _controller.text;
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
        clearButtonEvent: () {
          _controller.clear();
          setState(() {
            _currentInput = '';
          });
        },
        onChanged: (text) {
          setState(() {
            _currentInput = text;
          });
        },
        onFieldSubmitted: (text) async {
          if (text.trim().isNotEmpty) {
            await Navigator.pushNamed(
              context,
              SearchResultScreen.route,
              arguments: SearchResultScreenArguments(keyword: text),
            );
            // 検索結果画面から戻ってくるとき、この画面はスルーする
            Navigator.of(context).pop();
          } else {
            _controller.clear();
            setState(() {
              _currentInput = '';
            });
          }
        },
      ),
      body: ChangeNotifierProvider(
        create: (_) => SearchingViewModel()..init(),
        child: Consumer<SearchingViewModel>(
          builder: (context, viewModel, _) {
            final state = viewModel.getState() ?? SearchingScreenLoading();

            if (state is SearchingScreenLoadSuccess) {
              final histories = state.histories;

              // historiesをdeep copyして利用する
              final suggestions = [...histories]
                ..retainWhere((s) => s.contains(_currentInput ?? ''));

              if (histories.isNotEmpty) {
                return Scrollbar(
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      return _SearchHistoryCell(
                        keyword: suggestions[index],
                        deleteEvent: () async {
                          await viewModel.deleteSearchKeyword(
                            keyword: suggestions[index] ?? '',
                          );
                        },
                      );
                    },
                    separatorBuilder: (context, _) => CustomDivider(),
                    itemCount: suggestions.length,
                  ),
                );
              } else {
                return Center(
                  child: _currentInput.isEmpty
                      ? const Text('検索履歴はありません')
                      : Container(),
                );
              }
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
  @required TextEditingController controller,
  @required void Function() clearButtonEvent,
  @required void Function(String) onChanged,
  @required void Function(String) onFieldSubmitted,
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(50),
    child: AppBar(
      titleSpacing: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: clearButtonEvent,
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
            onChanged: onChanged,
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

class _SearchHistoryCell extends StatelessWidget {
  const _SearchHistoryCell({
    @required this.keyword,
    @required this.deleteEvent,
  });

  final String keyword;
  final void Function() deleteEvent;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: const SlidableScrollActionPane(),
      secondaryActions: [
        IconSlideAction(
          icon: Icons.delete,
          color: Theme.of(context).errorColor,
          onTap: deleteEvent,
        ),
      ],
      child: Ink(
        decoration: const BoxDecoration(
          color: AppColors.grey20,
        ),
        child: ListTile(
          title: Text(keyword ?? ''),
          onTap: () async {
            FocusScope.of(context).unfocus();
            await Navigator.pushNamed(
              context,
              SearchResultScreen.route,
              arguments: SearchResultScreenArguments(
                keyword: keyword ?? '',
              ),
            );
            // 検索結果画面から戻ってくるとき、この画面はスルーする
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
