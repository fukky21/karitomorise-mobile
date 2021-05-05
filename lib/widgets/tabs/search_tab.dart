import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../notifiers/index.dart';
import '../../repositories/index.dart';
import '../../widgets/components/index.dart';
import '../../widgets/screens/index.dart';

class SearchTab extends StatelessWidget {
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
            onPressed: () => Navigator.pushNamed(context, SearchScreen.route),
          ),
        ],
      ),
      body: ChangeNotifierProvider(
        create: (context) => SearchTabStateNotifier(
          publicRepository: context.read<FirebasePublicRepository>(),
        ),
        child: Consumer<SearchTabStateNotifier>(
          builder: (context, notifier, _) {
            final state = notifier?.state ?? SearchTabLoading();

            if (state is SearchTabLoadFailure) {
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
                        onPressed: () async {
                          await notifier.init();
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is SearchTabLoadSuccess) {
              return RefreshIndicator(
                onRefresh: () async {
                  await notifier.init();
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
