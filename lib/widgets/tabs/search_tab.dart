import 'package:flutter/material.dart';

import '../../widgets/components/index.dart';
import '../../widgets/screens/index.dart';

class SearchTab extends StatelessWidget {
  static const _appBarTitle = 'さがす';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(context, title: _appBarTitle),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomDivider(),
            EventCell(
              eventId: null,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  ShowEventScreen.route,
                  arguments: ShowEventScreenArguments(
                    eventId: 'ehpoTaX3Ta78uNHQEZ6x',
                  ),
                );
              },
            ),
            CustomDivider(),
          ],
        ),
      ),
    );
  }
}
