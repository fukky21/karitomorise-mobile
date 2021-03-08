import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../utils/index.dart';

void showSnackBar(BuildContext context, String message) {
  Scaffold.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: AppColors.grey10,
        behavior: SnackBarBehavior.floating,
        content: AutoSizeText(
          message,
          style: const TextStyle(color: AppColors.white),
          maxLines: 1,
        ),
        action: SnackBarAction(
          label: 'とじる',
          textColor: AppColors.white,
          onPressed: () => Scaffold.of(context).removeCurrentSnackBar(),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
}
