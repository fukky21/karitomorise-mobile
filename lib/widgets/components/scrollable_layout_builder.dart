import 'package:flutter/material.dart';

class ScrollableLayoutBuilder extends StatelessWidget {
  const ScrollableLayoutBuilder({
    @required this.child,
    this.controller,
    this.alwaysScrollable = false,
  });

  final Widget child;
  final ScrollController controller;
  final bool alwaysScrollable;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        controller: controller,
        physics:
            alwaysScrollable ? const AlwaysScrollableScrollPhysics() : null,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: child,
        ),
      ),
    );
  }
}
