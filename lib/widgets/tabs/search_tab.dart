import 'package:flutter/material.dart';

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
      body: const Center(
        child: Text('SEARCH'),
      ),
    );
  }
}
