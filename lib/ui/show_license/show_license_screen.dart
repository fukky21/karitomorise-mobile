import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_divider.dart';

class ShowLicenseScreen extends StatefulWidget {
  static const route = '/show_licence';

  @override
  _ShowLicenseScreenState createState() => _ShowLicenseScreenState();
}

class _ShowLicenseScreenState extends State<ShowLicenseScreen> {
  final _appBarTitle = 'ライセンス';
  List<List<String>> licenses = [];

  @override
  void initState() {
    super.initState();
    LicenseRegistry.licenses.listen((license) {
      final packages = license.packages.toList();
      final paragraphs = license.paragraphs.toList();
      final packageName = packages.map((e) => e).join('');
      final paragraphText = paragraphs.map((e) => e.text).join('\n');
      licenses.add([packageName, paragraphText]);
      setState(() => licenses = licenses);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cells = <Widget>[];
    for (final license in licenses) {
      final cell = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${license[0]}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              '${license[1]}',
              style: const TextStyle(fontSize: 12),
            )
          ],
        ),
      );
      cells.add(cell);
    }

    return Scaffold(
      appBar: simpleAppBar(context, title: _appBarTitle),
      body: Scrollbar(
        child: ListView.separated(
          separatorBuilder: (context, _) => CustomDivider(),
          itemBuilder: (context, index) {
            return cells[index];
          },
          itemCount: cells.length,
        ),
      ),
    );
  }
}
