import 'package:flutter/material.dart';

import '../../utils/index.dart';

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

PreferredSizeWidget searchAppBar(
  BuildContext context, {
  String initialValue,
  bool autofocus = false,
  void Function(String) onFieldSubmitted,
  void Function() onTap,
  List<Widget> actions,
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(50),
    child: AppBar(
      titleSpacing: 0,
      actions: actions,
      title: Material(
        color: AppColors.transparent,
        child: SizedBox(
          height: 40,
          child: TextFormField(
            autofocus: autofocus,
            initialValue: initialValue,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: '直近の募集を検索',
              border: InputBorder.none,
            ),
            onFieldSubmitted: onFieldSubmitted,
            onTap: onTap,
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
