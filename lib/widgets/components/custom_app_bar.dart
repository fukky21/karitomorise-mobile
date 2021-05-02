import 'package:flutter/material.dart';

import '../../util/index.dart';

PreferredSizeWidget simpleAppBar(
  BuildContext context, {
  String title,
  List<Widget> actions,
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(50),
    child: AppBar(
      title: Text(
        title ?? '',
        style: Theme.of(context)
            .textTheme
            .subtitle1
            .copyWith(fontWeight: FontWeight.bold),
      ),
      actions: actions,
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

PreferredSizeWidget transparentAppBar(BuildContext context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(50),
    child: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}
