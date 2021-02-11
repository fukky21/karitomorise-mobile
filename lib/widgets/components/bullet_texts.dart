import 'package:flutter/material.dart';

class BulletTexts extends StatelessWidget {
  const BulletTexts({@required this.texts, this.style});

  final List<String> texts;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final _list = <Widget>[];
    for (final text in texts) {
      _list.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('● ', style: style),
            Flexible(
              child: Text(text, style: style),
            ),
          ],
        ),
      );
    }
    return Column(children: _list);
  }
}
