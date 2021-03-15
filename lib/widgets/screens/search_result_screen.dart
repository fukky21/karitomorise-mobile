import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../blocs/search_result_screen_bloc/index.dart';
import '../../widgets/components/index.dart';
import 'search_screen.dart';
import 'show_event_screen.dart';

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
    return BlocProvider<SearchResultScreenBloc>(
      create: (context) => SearchResultScreenBloc(context: context)
        ..add(Initialized(keyword: widget?.args?.keyword ?? '')),
      child: Scaffold(
        appBar: searchAppBar(
          context,
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              child: IconButton(
                icon: const Icon(FontAwesomeIcons.slidersH),
                onPressed: () {
                  // TODO(Fukky21): 絞り込み機能を実装する
                },
              ),
            ),
          ],
          initialValue: widget?.args?.keyword ?? '',
          onTap: () {
            FocusScope.of(context).requestFocus(_focusNode);
            Navigator.pushNamed(
              context,
              SearchScreen.route,
              arguments: SearchScreenArguments(
                initialValue: widget?.args?.keyword,
              ),
            );
          },
        ),
        body: BlocBuilder<SearchResultScreenBloc, SearchResultScreenState>(
          builder: (context, state) {
            if (state == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state.eventIds.isEmpty) {
              return const Center(
                child: Text('検索結果はありません'),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<SearchResultScreenBloc>()
                    .add(Initialized(keyword: widget?.args?.keyword ?? ''));
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.eventIds.length,
                itemBuilder: (context, index) {
                  if (index == state.eventIds.length - 1 &&
                      state.isFetchabled) {
                    context.read<SearchResultScreenBloc>().add(Fetched());
                  }
                  return EventCell(
                    eventId: state.eventIds[index],
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        ShowEventScreen.route,
                        arguments: ShowEventScreenArguments(
                          eventId: state.eventIds[index],
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (context, _) => CustomDivider(),
              ),
            );
          },
        ),
      ),
    );
  }
}
