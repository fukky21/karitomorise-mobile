import 'package:flutter/material.dart';

class ScrollableLayoutBuilder extends StatelessWidget {
  const ScrollableLayoutBuilder({@required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: body,
        ),
      ),
    );
  }
}
